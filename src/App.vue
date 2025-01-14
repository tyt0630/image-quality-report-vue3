<script setup>
import { ref, onMounted, computed } from 'vue'
import Chart from 'chart.js/auto'
import { ElMessage } from 'element-plus'

const totalImages = ref(200)
const showPreview = ref(false)
const selectedType = ref(null)
const selectedServices = ref([])
const showSuccessModal = ref(false)
const showFormModal = ref(false)
const formData = ref({
  qps: '',
  billingAppkey: '',
  sceneName: '',
  businessContact: '',
  businessGroup: '',
  relatedDemand: '',
  materialType: ''
})

const imageTypes = [
  { 
    name: '黑白边', 
    count: 50, 
    percentage: 25,
    service: '黑白边识别',
    examples: Array(50).fill(null).map((_, index) => ({
      url: ['/examples/black-border-1.jpg', '/examples/black-border-2.jpg', '/examples/black-border-3.jpg', '/examples/black-border-4.jpg', '/examples/black-border-5.jpg'][index % 5],
      description: [
        '商品图片四周出现黑边',
        '局部区域出现黑边',
        '图片边缘出现白边',
        '图片周围有明显边框',
        '不规则黑白边'
      ][index % 5]
    }))
  },
  { 
    name: '重复图片', 
    count: 40, 
    percentage: 20,
    service: '重复图识别',
    examples: Array(40).fill(null).map((_, index) => ({
      url: ['/examples/duplicate-1.jpg', '/examples/duplicate-2.jpg', '/examples/duplicate-3.jpg', '/examples/duplicate-4.jpg'][index % 4],
      description: [
        '同一商品重复上传',
        '相似角度重复拍摄',
        '不同光线重复拍摄',
        '细节图重复使用'
      ][index % 4]
    }))
  },
  { 
    name: '水印图片', 
    count: 30, 
    percentage: 15,
    service: '水印识别',
    examples: Array(30).fill(null).map((_, index) => ({
      url: ['/examples/watermark-1.jpg', '/examples/watermark-2.jpg', '/examples/watermark-3.jpg'][index % 3],
      description: [
        '图片包含水印标记',
        '图片包含透明水印',
        '图片包含品牌水印'
      ][index % 3]
    }))
  },
  { 
    name: '拼接图片', 
    count: 30, 
    percentage: 15,
    service: '拼接图检测',
    examples: Array(30).fill(null).map((_, index) => ({
      url: ['/examples/composite-1.jpg', '/examples/composite-2.jpg', '/examples/composite-3.jpg'][index % 3],
      description: [
        '多张图片拼接上传',
        '商品细节拼接展示',
        '不同角度拼接展示'
      ][index % 3]
    }))
  },
  { 
    name: '手机截图', 
    count: 30, 
    percentage: 15,
    service: '手机截图识别',
    examples: Array(30).fill(null).map((_, index) => ({
      url: ['/examples/screenshot-1.jpg', '/examples/screenshot-2.jpg', '/examples/screenshot-3.jpg'][index % 3],
      description: [
        '手机界面截图上传',
        '包含状态栏的截图',
        '应用内截图上传'
      ][index % 3]
    }))
  },
  { 
    name: '误拍图片', 
    count: 20, 
    percentage: 10,
    service: '手持误拍识别',
    examples: Array(20).fill(null).map((_, index) => ({
      url: ['/examples/misshot-1.jpg', '/examples/misshot-2.jpg'][index % 2],
      description: [
        '图片模糊或失焦',
        '拍摄角度不当'
      ][index % 2]
    }))
  }
]

const sortedImageTypes = [...imageTypes].sort((a, b) => b.percentage - a.percentage)

// 只获取有问题的图片类型对应的服务
const services = computed(() => {
  return sortedImageTypes
    .filter(type => type.count > 0)
    .map(type => type.service)
})

// 服务能力描述
const serviceDescriptions = {
  '黑白边识别': '检测给定的商品图像是否存在黑边/白边框',
  '重复图识别': '提取图像特征进行比对，判断两张图像是否重复',
  '水印识别': '检测给定图像中是否含有水印，支持半透明效果水印',
  '拼接图检测': '检测给定的图像是否存在拼接，用于判断图像背景是否因无关信息过多导致画面杂乱',
  '手机截图识别': '检测给定图像是否包含手机状态栏，用于判断图像是否为手机截图',
  '手持误拍识别': '识别商品图片是否存在手持、模糊等问题'
}

const openPreview = (type) => {
  selectedType.value = type
  showPreview.value = true
}

const closePreview = () => {
  showPreview.value = false
  selectedType.value = null
}

const toggleService = (service) => {
  const index = selectedServices.value.indexOf(service)
  if (index === -1) {
    selectedServices.value.push(service)
  } else {
    selectedServices.value.splice(index, 1)
  }
}

const handleCreateScene = () => {
  showFormModal.value = true
}

const submitForm = () => {
  showFormModal.value = false
  showSuccessModal.value = true
  setTimeout(() => {
    showSuccessModal.value = false
  }, 3000)
}

const downloadResults = () => {
  // 生成CSV内容
  const headers = ['问题类型', '数量', '占比']
  const rows = sortedImageTypes.map(type => [type.name, type.count, `${type.percentage}%`])
  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.join(','))
  ].join('\n')

  // 创建Blob对象
  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  
  // 创建下载链接
  const link = document.createElement('a')
  link.href = url
  link.download = '图片质量诊断结果.csv'
  
  // 触发下载
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  
  // 清理URL对象
  URL.revokeObjectURL(url)
}

const showHelpTooltip = ref(false)

const formItems = [
  {
    label: '场景名称',
    key: 'sceneName',
    type: 'input',
    required: true,
    placeholder: '请输入场景名称'
  },
  {
    label: '业务对接人',
    key: 'businessContact',
    type: 'select',
    required: true,
    placeholder: '请输入业务对接人'
  },
  {
    label: '业务对接组',
    key: 'businessGroup',
    type: 'select',
    required: true,
    placeholder: '请输入业务对接组'
  },
  {
    label: '关联需求',
    key: 'relatedDemand',
    type: 'select',
    required: false,
    placeholder: '请输入关联需求'
  },
  {
    label: '素材类型',
    key: 'materialType',
    type: 'select',
    required: true,
    options: [
      { label: '图片', value: 'image' },
      { label: '视频', value: 'video' },
      { label: '文本', value: 'text' }
    ]
  },
  {
    label: 'QPS申请量',
    key: 'qps',
    type: 'input',
    required: true,
    placeholder: '请输入QPS申请量'
  },
  {
    label: '授权Appkey',
    key: 'authAppkey',
    type: 'input',
    required: true,
    placeholder: '请输入授权Appkey'
  },
  {
    label: '计费Appkey',
    key: 'billingAppkey',
    type: 'input',
    required: true,
    placeholder: '请输入计费Appkey'
  }
]

const activeDropdown = ref(null)

const toggleDropdown = (key) => {
  activeDropdown.value = activeDropdown.value === key ? null : key
}

const selectOption = (key, value) => {
  const index = formData.value[key].indexOf(value)
  if (index === -1) {
    formData.value[key].push(value)
  } else {
    formData.value[key].splice(index, 1)
  }
}

const handleExtraButtonClick = (action) => {
  if (action === 'createNewDemand') {
    // 处理创建新需求的逻辑
    console.log('创建新需求')
  }
}

const closeModal = () => {
  showFormModal.value = false
}

const handleSubmit = () => {
  // 提交成功后显示提示
  ElMessage.success({
    message: '创建成功，请到玉树-控制台-场景管理查看',
    duration: 3000  // 显示3秒
  })
}

const imageIssuesData = ref([
  { 
    id: 1, 
    count: 15, 
    thumbnail: '/examples/black-border-1.jpg', 
    issues: [
      '黑白边',
      '水印图片',
      '拼接图片',
      '重复图片',
      '手机截图',
      '误拍图片',
      '黑白边-左侧',
      '黑白边-右侧',
      '水印-左上角',
      '水印-右下角',
      '拼接-横向',
      '拼接-纵向',
      '重复-相似角度',
      '重复-不同光线',
      '模糊'
    ]
  },
  { 
    id: 2, 
    count: 12, 
    thumbnail: '/examples/watermark-2.jpg', 
    issues: [
      '水印图片',
      '重复图片',
      '手机截图',
      '水印-中心',
      '水印-四角',
      '水印-半透明',
      '重复-正面',
      '重复-侧面',
      '截图-状态栏',
      '截图-导航栏',
      '截图-应用内',
      '模糊'
    ]
  },
  { 
    id: 3, 
    count: 10, 
    thumbnail: '/examples/composite-2.jpg', 
    issues: [
      '拼接图片',
      '水印图片',
      '重复图片',
      '拼接-多张',
      '拼接-不规则',
      '水印-品牌',
      '水印-文字',
      '重复-细节',
      '重复-场景',
      '模糊'
    ]
  },
  { 
    id: 4, 
    count: 8, 
    thumbnail: '/examples/screenshot-2.jpg', 
    issues: [
      '手机截图',
      '水印图片',
      '截图-全屏',
      '截图-局部',
      '水印-角落',
      '水印-中央',
      '模糊',
      '变形'
    ]
  },
  { 
    id: 5, 
    count: 6, 
    thumbnail: '/examples/misshot-1.jpg', 
    issues: [
      '误拍图片',
      '重复图片',
      '模糊',
      '光线不足',
      '角度不当',
      '手抖'
    ]
  },
  { 
    id: 6, 
    count: 4, 
    thumbnail: '/examples/black-border-2.jpg', 
    issues: [
      '黑白边',
      '黑白边-上方',
      '黑白边-下方',
      '变形'
    ]
  },
  { 
    id: 7, 
    count: 3, 
    thumbnail: '/examples/composite-1.jpg', 
    issues: [
      '拼接图片',
      '拼接-横向',
      '拼接-不对齐'
    ]
  },
  { 
    id: 8, 
    count: 2, 
    thumbnail: '/examples/screenshot-1.jpg', 
    issues: [
      '手机截图',
      '截图-状态栏'
    ]
  }
])

const selectedIssueImage = ref(null)
const showIssueDetail = ref(false)

const openIssueDetail = (image) => {
  selectedIssueImage.value = image
  showIssueDetail.value = true
}

const closeIssueDetail = () => {
  showIssueDetail.value = false
  selectedIssueImage.value = null
}

onMounted(() => {
  const ctx = document.getElementById('qualityChart')
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: sortedImageTypes.map(type => type.name),
      datasets: [{
        data: sortedImageTypes.map(type => type.count),
        backgroundColor: [
          'rgba(255, 192, 203, 0.5)',  // 粉色 - 黑白边
          'rgba(144, 238, 144, 0.5)',  // 淡绿色 - 重复图片
          'rgba(135, 206, 235, 0.5)',  // 天蓝色 - 水印图片
          'rgba(221, 160, 221, 0.5)',  // 梅红色 - 拼接图片
          'rgba(255, 218, 185, 0.5)',   // 桔色 - 手机截图
          'rgba(255, 228, 181, 0.5)'  // 杏色 - 误拍图片
        ],
        borderWidth: 0,
        barThickness: 60,
        borderRadius: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        title: {
          display: true,
          text: '低质类型分布',
          font: {
            size: 16,
            weight: 'normal'
          },
          padding: {
            top: 10,
            bottom: 20
          }
        },
        tooltip: {
          callbacks: {
            title: function(context) {
              return context[0].label;
            },
            label: function(context) {
              const type = sortedImageTypes[context.dataIndex];
              return [
                `数量: ${type.count}张`,
                `占比: ${type.percentage}%`
              ];
            }
          },
          backgroundColor: 'rgba(255, 255, 255, 0.9)',
          titleColor: '#333',
          bodyColor: '#666',
          borderColor: '#ddd',
          borderWidth: 1,
          padding: 10,
          cornerRadius: 4,
          displayColors: false,
          titleFont: {
            size: 14,
            weight: 'bold'
          },
          bodyFont: {
            size: 13
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          max: 50,
          ticks: {
            stepSize: 10,
            callback: function(value) {
              return value + '张';
            },
            font: {
              size: 12,
              color: '#999'
            },
            padding: 8
          },
          grid: {
            color: 'rgba(0, 0, 0, 0.05)',
            drawBorder: false,
            lineWidth: 1
          }
        },
        x: {
          grid: {
            display: false
          },
          ticks: {
            font: {
              size: 12,
              color: '#666'
            },
            padding: 8
          }
        }
      },
      layout: {
        padding: {
          left: 10,
          right: 10,
          top: 10,
          bottom: 10
        }
      },
      onClick: (event, elements) => {
        if (elements.length > 0) {
          const index = elements[0].index;
          const type = imageTypes[index];
          openPreview(type);
        }
      }
    }
  })

  // 添加图片质量问题分布图表
  const issuesCtx = document.getElementById('issuesDistributionChart')
  new Chart(issuesCtx, {
    type: 'bar',
    data: {
      labels: imageIssuesData.value.map(img => `图片${img.id}`),
      datasets: [{
        label: '低质问题数量',
        data: imageIssuesData.value.map(img => img.count),
        backgroundColor: 'rgba(100, 180, 255, 0.6)',
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      onClick: (event, elements) => {
        if (elements.length > 0) {
          const index = elements[0].index;
          const image = imageIssuesData.value[index];
          openIssueDetail(image);
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          max: 15,
          min: 0,
          ticks: {
            stepSize: 3,
            callback: function(value) {
              return value + '个';
            }
          },
          title: {
            display: true,
            text: '低质问题数量'
          }
        },
        x: {
          title: {
            display: true,
            text: '图片编号'
          }
        }
      },
      plugins: {
        legend: {
          display: false
        },
        title: {
          display: true,
          text: '图片低质问题数量',
          font: {
            size: 16,
            weight: 'normal'
          },
          padding: {
            top: 10,
            bottom: 20
          }
        },
        tooltip: {
          callbacks: {
            title: function(tooltipItems) {
              return `图片${tooltipItems[0].dataIndex + 1}`;
            },
            label: function(context) {
              const image = imageIssuesData.value[context.dataIndex]
              return [
                `问题数量: ${image.count}个`,
                `存在问题: ${image.issues.join('、')}`
              ]
            }
          }
        }
      }
    }
  })
})
</script>

<template>
  <div class="container">
    <div class="report-header">
      <h1>图像质量诊断报告
        <a href="https://km.sankuai.com/collabpage/2693732140" 
           target="_blank" 
           class="title-help-icon"
           @mouseenter="showHelpTooltip = true"
           @mouseleave="showHelpTooltip = false">
          <span class="icon">!</span>
          <div class="tooltip" v-if="showHelpTooltip">报告解释说明</div>
        </a>
      </h1>
    </div>
    <div class="diagnosis-section">
      <div class="section-header">
        <h2>诊断结果</h2>
        <button class="download-button" @click="downloadResults">
          <span class="download-icon">↓</span>
          下载明细结果
        </button>
      </div>
      <div class="diagnosis-summary">
        <div class="summary-content">
          <div class="count">本次共诊断了<span class="number">{{ totalImages }}</span>张图片</div>
          <div class="description">本次调用了手持误拍识别、手机截图识别、拼接图检测、白底图识别、变形图识别、黑白边识别、卖点贴识别、重复图识别、包装图检测、背标图检测、二维码/条形码检测、商品质量异常检测、角度旋转检测、光线图识别、水印识别的服务</div>
          <div class="hint">低质图片类型如下所示：</div>
        </div>
      </div>
      
      <div class="image-types">
        <div 
          v-for="type in sortedImageTypes" 
          :key="type.name" 
          class="image-type"
          @click="openPreview(type)"
        >
          <div class="type-name">{{ type.name }}</div>
          <div class="type-count">{{ type.count }}张 ({{ type.percentage }}%)</div>
        </div>
      </div>

      <div class="chart-section">
        <div class="chart-container quality-distribution">
          <canvas id="qualityChart"></canvas>
        </div>
        
        <!-- 添加新的图表容器 -->
        <div class="chart-container issues-distribution">
          <canvas id="issuesDistributionChart"></canvas>
        </div>
      </div>
    </div>

    <div class="services-section">
      <h2>推荐服务</h2>
      <div class="service-description">
        <p>根据本次诊断图片的低质类型，为您推荐以下服务</p>
        <p>多选您所需要的服务，一键接入玉树</p>
      </div>
      <div class="service-tags">
        <div v-for="service in services" 
             :key="service" 
             :class="['service-tag', { active: selectedServices.includes(service) }]"
             @click="toggleService(service)">
          {{ service }}
          <div class="service-tooltip">{{ serviceDescriptions[service] }}</div>
        </div>
      </div>
      <button class="contact-button" style="background-color: #165DFF;" @click="handleCreateScene">生成接入场景</button>
    </div>

    <!-- 图片预览弹窗 -->
    <div v-if="showPreview" class="modal-overlay" @click.self="closePreview">
      <div class="modal-content preview-modal">
        <button class="close-button" @click="closePreview">×</button>
        <div class="preview-content">
          <h2>{{selectedType.name}} - 示例</h2>
          <div class="examples-grid">
            <div v-for="example in selectedType.examples" 
                 :key="example.url" 
                 class="example-item">
              <div class="example-image">
                <img :src="example.url" :alt="example.description">
              </div>
              <div class="example-description">
                {{example.description}}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 表单弹窗 -->
    <div v-if="showFormModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <button class="close-button" @click="closeModal">×</button>
        <h2 class="modal-title">创建接入场景</h2>
        <div class="form-container">
          <div class="form-item">
            <div class="form-label">场景名称</div>
            <div class="input-container">
              <input v-model="formData.sceneName" placeholder="请输入场景名称" type="text">
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">业务对接人</div>
            <div class="input-container">
              <input v-model="formData.businessContact" placeholder="请输入业务对接人" type="text">
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">业务对接组</div>
            <div class="input-container">
              <input v-model="formData.businessGroup" placeholder="请输入业务对接组" type="text">
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">
              关联需求
              <a href="https://ones.sankuai.com/ones/product/49032/workItem/requirement/list?filterId=41&cn=1&showType=list%E2%80%8B"
                 target="_blank"
                 class="create-demand-link"
                 style="position: absolute; left: 0; top: -20px; font-size: 12px; color: #165DFF; text-decoration: none; white-space: nowrap;">
                新建需求
              </a>
            </div>
            <div class="input-container">
              <input v-model="formData.relatedDemand" placeholder="请输入关联需求" type="text">
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">素材类型</div>
            <div class="input-container">
              <div class="select-input" @click="toggleDropdown('materialType')" style="text-align: left;">
                <span v-if="!formData.materialType"></span>
                <span v-else>{{ formItems.find(item => item.key === 'materialType').options.find(opt => opt.value === formData.materialType)?.label }}</span>
              </div>
              <div v-if="activeDropdown === 'materialType'" class="dropdown-content">
                <div v-for="option in formItems.find(item => item.key === 'materialType').options"
                     :key="option.value"
                     class="dropdown-item"
                     @click="formData.materialType = option.value; activeDropdown = null">
                  {{ option.label }}
                  <span v-if="formData.materialType === option.value" class="selected-mark">✓</span>
                </div>
              </div>
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">QPS申请量</div>
            <div class="input-container">
              <input v-model="formData.qps" placeholder="请输入QPS申请量" type="number">
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">授权Appkey</div>
            <div class="input-container">
              <input value="com.sankuai.horus.yushusvc" disabled type="text">
            </div>
          </div>

          <div class="form-item">
            <div class="form-label">计费Appkey</div>
            <div class="input-container">
              <input v-model="formData.billingAppkey" placeholder="请输入计费Appkey" type="text">
            </div>
          </div>
        </div>
        <div class="modal-buttons">
          <button class="submit-button" @click="handleSubmit">接入</button>
        </div>
      </div>
    </div>

    <!-- 成功提示弹窗 -->
    <div v-if="showSuccessModal" class="success-modal">
      <div class="success-content">
        <div class="success-icon">✓</div>
        <div class="success-message">创建成功，请到玉树-控制台-场景管理查看</div>
      </div>
    </div>

    <!-- 图片问题详情弹窗 -->
    <div v-if="showIssueDetail" class="modal-overlay" @click.self="closeIssueDetail">
      <div class="modal-content issue-detail-modal">
        <button class="close-button" @click="closeIssueDetail">×</button>
        <div class="issue-detail-content">
          <!-- 上部分：图片展示 -->
          <div class="issue-image-section">
            <img :src="selectedIssueImage?.thumbnail" alt="问题图片">
            <div class="image-info">
              <h3>图片 {{selectedIssueImage?.id}}</h3>
              <div class="issue-count">发现 {{selectedIssueImage?.count}} 个问题</div>
            </div>
          </div>
          <!-- 下部分：问题列表 -->
          <div class="issue-list-section">
            <div class="issue-list-header">存在的问题：</div>
            <div class="issues-scroll">
              <div class="issues-row">
                <div v-for="issue in selectedIssueImage?.issues" 
                     :key="issue" 
                     class="issue-tag">
                  {{issue}}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 40px;
  font-family: Arial, sans-serif;
  background-color: #f8f9fa;
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 40px;
  font-size: 28px;
}

h2 {
  color: #444;
  margin-bottom: 15px;
  font-size: 20px;
}

.report-header {
  position: relative;
  display: inline-block;
  margin-bottom: 20px;
}

.report-header h1 {
  margin: 0;
}

.title-help-icon {
  position: absolute;
  right: -24px;
  top: 4px;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background-color: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  transition: all 0.2s;
}

.title-help-icon .icon {
  color: #666;
  font-size: 12px;
  font-weight: bold;
  font-style: normal;
}

.title-help-icon:hover {
  background-color: #dee2e6;
}

.title-help-icon .tooltip {
  position: absolute;
  visibility: visible;
  top: -30px;
  left: 50%;
  transform: translateX(-50%);
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  white-space: nowrap;
  pointer-events: none;
}

.title-help-icon .tooltip::after {
  content: "";
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border-width: 4px;
  border-style: solid;
  border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
}

.title-help-icon:hover .tooltip {
  visibility: visible;
}

.help-icon {
  display: inline-block;
  width: 16px;
  height: 16px;
  line-height: 16px;
  text-align: center;
  border-radius: 50%;
  background-color: #e6f7ff;
  color: #1890ff;
  margin-left: 8px;
  cursor: help;
  font-size: 12px;
  font-style: normal;
  border: 1px solid #91d5ff;
}

.help-icon:hover {
  background-color: #1890ff;
  color: white;
  border-color: #1890ff;
}

.help-icon .tooltip {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  padding: 8px 12px;
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  font-size: 12px;
  border-radius: 4px;
  white-space: nowrap;
  margin-bottom: 8px;
  z-index: 1000;
}

.help-icon .tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border-width: 5px;
  border-style: solid;
  border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
}

.help-icon:hover .tooltip {
  visibility: visible;
}

.diagnosis-section, .services-section {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 30px;
}

.diagnosis-summary {
  font-size: 14px;
  color: #666;
  margin: 20px 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.summary-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  max-width: 800px;
  text-align: center;
}

.summary-content .number {
  color: #1890ff;
  font-weight: bold;
  margin: 0 2px;
}

.summary-content .description,
.summary-content .hint {
  line-height: 1.5;
}

.image-types {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 30px;
  padding: 0 20px;
}

.image-type {
  text-align: left;
  cursor: pointer;
  padding: 20px;
  border-radius: 12px;
  transition: all 0.2s;
  background-color: #f8f9fa;
  border: 1px solid #eee;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.image-type:hover {
  background: #f1f3f5;
  transform: translateY(-1px);
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.08);
}

.type-name {
  font-weight: bold;
  margin-bottom: 8px;
  font-size: 16px;
  color: #333;
}

.type-count {
  color: #666;
  font-size: 14px;
}

.service-tags {
  text-align: left;
  margin-bottom: 30px;
}

.service-tag {
  display: inline-block;
  padding: 8px 16px;
  margin: 6px;
  border-radius: 20px;
  background-color: #f8f9fa;
  color: #666;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #eee;
  position: relative;
}

.service-tag:hover {
  background-color: #f1f3f5;
  transform: translateY(-1px);
}

.service-tag.active {
  background-color: #e7f5ff;
  color: #228be6;
  border-color: #228be6;
}

.service-tooltip {
  visibility: hidden;
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  padding: 8px 12px;
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  font-size: 12px;
  border-radius: 4px;
  white-space: nowrap;
  margin-bottom: 8px;
  z-index: 1000;
}

.service-tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border-width: 5px;
  border-style: solid;
  border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
}

.service-tag:hover .service-tooltip {
  visibility: visible;
}

.contact-button {
  padding: 12px 30px;
  background: #165DFF;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 16px;
  margin-left: 10px;
}

.contact-button:hover {
  background: #0E42D2;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.services-section {
  margin-top: 40px;
}

.services-section h2 {
  font-size: 24px;
  margin-bottom: 16px;
}

.services-section .description {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
}

.service-description {
  text-align: center;
  color: #666;
  font-size: 14px;
  margin: 15px 0;
}

.service-description p {
  margin: 8px 0;
}

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 32px;
  border-radius: 8px;
  width: 480px;
  max-width: 90%;
  position: relative;
}

.modal-title {
  margin: 0 0 32px 0;
  font-size: 16px;
  color: #333;
  text-align: center;
  font-weight: normal;
}

.form-container {
  margin: 0;
}

.form-item {
  margin-bottom: 24px;
  display: flex;
  align-items: center;
}

.form-item:last-child {
  margin-bottom: 32px;
}

.form-label {
  width: 90px;
  flex-shrink: 0;
  color: #333;
  font-size: 14px;
  margin-right: 12px;
  position: relative;
}

.input-container {
  flex: 1;
  position: relative;
}

.form-item input,
.select-input,
.multiselect-input {
  width: 100%;
  height: 40px;
  padding: 8px 12px;
  border: 1px solid #e5e6eb;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
  background: white;
  color: #333;
}

.form-item input::placeholder,
.select-input::placeholder,
.multiselect-input .placeholder {
  color: #86909c;
}

.form-item input:hover,
.select-input:hover,
.multiselect-input:hover {
  border-color: #165DFF;
}

.form-item input:focus,
.select-input:focus,
.multiselect-input:focus {
  border-color: #165DFF;
  outline: none;
  box-shadow: 0 0 0 2px rgba(22, 93, 255, 0.1);
}

.select-container,
.multiselect-container {
  position: relative;
  width: 100%;
}

.select-arrow {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #86909c;
  font-size: 12px;
  pointer-events: none;
}

.modal-buttons {
  display: flex;
  justify-content: center;
  margin-top: 8px;
}

.submit-button {
  padding: 8px 24px;
  background: #165DFF;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.submit-button:hover {
  background: #0E42D2;
}

.close-button {
  position: absolute;
  right: 16px;
  top: 16px;
  width: 24px;
  height: 24px;
  border: none;
  background: none;
  font-size: 20px;
  color: #4E5969;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border-radius: 50%;
  transition: all 0.2s;
}

.close-button:hover {
  background-color: rgba(0, 0, 0, 0.04);
  color: #1D2129;
}

.success-modal {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0, 0, 0, 0.8);
  padding: 16px 24px;
  border-radius: 8px;
  z-index: 2000;
  animation: fadeIn 0.3s ease;
}

.success-content {
  display: flex;
  align-items: center;
  gap: 12px;
  color: white;
}

.success-icon {
  font-size: 20px;
  color: #52c41a;
}

.success-message {
  font-size: 14px;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translate(-50%, -40%);
  }
  to {
    opacity: 1;
    transform: translate(-50%, -50%);
  }
}

.section-header {
  position: relative;
  text-align: center;
  margin-bottom: 16px;
}

.section-header h2 {
  margin: 0;
}

.download-button {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 20px;
  color: #666;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}

.download-button:hover {
  background-color: #e9ecef;
  border-color: #ccc;
}

.download-icon {
  font-size: 16px;
  font-weight: bold;
}

input:disabled {
  background-color: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

.create-demand-link {
  position: absolute;
  left: 0;
  top: -20px;
  font-size: 12px;
  color: #165DFF;
  text-decoration: none;
  white-space: nowrap;
}

.create-demand-link:hover {
  color: #0E42D2;
}

.dropdown-content {
  position: absolute;
  top: 100%;
  left: 0;
  width: 100%;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  z-index: 1000;
}

.dropdown-item {
  padding: 8px 12px;
  cursor: pointer;
  text-align: left;
  font-size: 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dropdown-item:hover {
  background-color: #f5f5f5;
}

.select-input {
  width: 100%;
  height: 32px;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 0 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  text-align: left;
}

.select-input span {
  text-align: left;
}

.chart-section {
  display: flex;
  flex-direction: column;
  gap: 30px;
  margin-top: 30px;
  align-items: center;  /* 居中对齐 */
}

.chart-container {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  height: 400px;  /* 设置固定高度 */
  width: 80%;  /* 设置为父容器的80%宽度 */
  max-width: 800px;  /* 设置最大宽度 */
}

.quality-distribution,
.issues-distribution {
  position: relative;
}

canvas {
  width: 100% !important;
  height: 100% !important;
}

.issue-detail-modal {
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  padding: 24px;
}

.issue-detail-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.issue-image-section {
  position: relative;
  width: 100%;
  background: #f8f9fa;
}

.issue-image-section img {
  width: 100%;
  height: 400px;
  object-fit: contain;
  display: block;
}

.image-info {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
  color: white;
}

.image-info h3 {
  margin: 0;
  font-size: 18px;
}

.issue-count {
  margin-top: 4px;
  font-size: 14px;
  opacity: 0.9;
}

.issue-list-section {
  padding: 24px;
}

.issue-list-header {
  font-weight: 600;
  color: #333;
  margin-bottom: 16px;
}

.issues-scroll {
  overflow-x: auto;
  padding-bottom: 8px;
}

.issues-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 4px;
}

.issue-tag {
  background: #f0f2f5;
  border-radius: 4px;
  padding: 8px 16px;
  color: #333;
  font-size: 14px;
  border: 1px solid #e4e7ed;
  transition: all 0.3s ease;
}

.issue-tag:hover {
  background: #e6f7ff;
  border-color: #91d5ff;
  color: #1890ff;
}

/* 自定义滚动条样式 */
.issues-scroll::-webkit-scrollbar {
  height: 6px;
}

.issues-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.issues-scroll::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}

.issues-scroll::-webkit-scrollbar-thumb:hover {
  background: #999;
}

.preview-modal {
  max-width: 900px;
  max-height: 80vh;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.preview-content {
  padding: 24px;
  overflow-y: auto;
}

.preview-content h2 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 20px;
  text-align: center;
}

.examples-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  padding: 4px;
}

.example-item {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease;
}

.example-item:hover {
  transform: translateY(-2px);
}

.example-image {
  position: relative;
  padding-top: 100%;
  background: #f5f7fa;
}

.example-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.example-description {
  padding: 12px;
  font-size: 14px;
  color: #333;
  text-align: center;
  background: #fff;
  border-top: 1px solid #eee;
}

/* 自定义滚动条样式 */
.preview-content::-webkit-scrollbar {
  width: 6px;
}

.preview-content::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.preview-content::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}

.preview-content::-webkit-scrollbar-thumb:hover {
  background: #999;
}
</style>
