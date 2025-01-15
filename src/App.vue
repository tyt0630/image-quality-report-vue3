<script setup>
import { ref, onMounted, computed } from 'vue'
import Chart from 'chart.js/auto'
import { ElMessage, ElTooltip, ElDialog } from 'element-plus'
import * as XLSX from 'xlsx'

const totalImages = ref(228)  // 改为228张图片
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

const imageTypes = ref([
  { name: '黑白边', count: 32, percentage: 12, service: '黑白边识别' },
  { name: '重复图片', count: 28, percentage: 10, service: '重复图识别' },
  { name: '水印图片', count: 24, percentage: 9, service: '水印识别' },
  { name: '拼接图片', count: 20, percentage: 7, service: '拼接图检测' },
  { name: '手机截图', count: 16, percentage: 6, service: '手机截图识别' },
  { name: '误拍图片', count: 16, percentage: 6, service: '手持误拍识别' },
  { name: '白底图片', count: 16, percentage: 6, service: '白底图识别' },
  { name: '变形图片', count: 12, percentage: 4, service: '变形图识别' },
  { name: '卖点贴图片', count: 12, percentage: 4, service: '卖点贴识别' },
  { name: '无包装图片', count: 12, percentage: 4, service: '包装图检测' },
  { name: '背标图片', count: 8, percentage: 3, service: '背标图检测' },
  { name: '二维码条形码', count: 8, percentage: 3, service: '二维码/条形码检测' },
  { name: '商品质量异常', count: 8, percentage: 3, service: '商品质量异常检测' },
  { name: '角度旋转', count: 8, percentage: 3, service: '角度旋转检测' },
  { name: '过亮或过暗', count: 8, percentage: 3, service: '光线图识别' }
])

const processedImageTypes = computed(() => {
  return imageTypes.value.map(type => ({
    ...type,
    examples: Array(type.count).fill(null).map((_, index) => ({
      url: placeholderImage
    }))
  }));
});

const sortedImageTypes = [...processedImageTypes.value].sort((a, b) => b.percentage - a.percentage)

// 只获取有问题的图片类型对应的服务
const services = computed(() => {
  return sortedImageTypes
    .filter(type => type.count > 0)
    .map(type => type.service)
})

// 服务列表
const servicesList = computed(() => {
  // 根据imageTypes中的数据对服务进行排序
  return imageTypes.value
    .sort((a, b) => b.percentage - a.percentage)
    .map(type => type.service)
    .filter((service, index, self) => self.indexOf(service) === index);
});

// 服务能力描述
const serviceDescriptions = ref({
  '变形图识别': '主要用于识别酒店图片是否变形',
  '白底图识别': '检测给定图像的背景(非主体部分)是否为纯色白底',
  '拼接图检测': '检测给定的图像是否存在拼接，用于判断图像背景是否因无关信息过多导致画面杂乱',
  '手机截图识别': '检测给定图像是否包含手机状态栏，用于判断图像是否为手机截图',
  '手持误拍识别': '识别误拍（模糊、纯色、渐变）',
  '黑白边识别': '检测给定的商品图像是否存在黑色/白色边框',
  '卖点贴识别': '检测给定的商品图像是否包含卖点贴(有宣传卖点等信息的图贴)',
  '重复图识别': '提取图像特征进行比对，判断两张图像是否重复',
  '包装图检测': '检测给定图像是否包含商品包装',
  '背标图检测': '检测给定的商品图像是否包含背标图',
  '二维码/条形码检测': '检测给定图像中是否包含二维码或条码',
  '商品质量异常检测': '检测给定图像主体是否存在商品破损、外卖盒倾洒，及其他外观异常情况',
  '角度旋转检测': '判断给定图像是否存在角度旋转',
  '光线图识别': '识别图像是否过亮或过暗',
  '水印识别': '检测给定图像中是否含有水印，支持半透明效果水印'
});

const showServiceDescription = ref('');

const getServiceDescription = (service) => {
  return serviceDescriptions.value[service] || service;
};

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
  // 创建工作簿
  const wb = XLSX.utils.book_new()

  // 第一个sheet：统计数据
  const statsHeaders = ['问题类型', '数量', '占比']
  const statsData = [
    statsHeaders,
    ...sortedImageTypes.map(type => [type.name, type.count, `${type.percentage}%`])
  ]
  const statsSheet = XLSX.utils.aoa_to_sheet(statsData)
  XLSX.utils.book_append_sheet(wb, statsSheet, '统计数据')

  // 第二个sheet：图片明细
  // 定义所有问题类型（按照指定顺序）
  const allIssueTypes = [
    '黑白边', '重复图片', '水印图片', '拼接图片', '手机截图',
    '误拍图片', '白底图片', '变形图片', '卖点贴图片', '无包装图片',
    '背标图片', '二维码条形码', '商品质量异常', '角度旋转', '过亮或过暗'
  ]
  
  // 创建表头
  const detailHeaders = ['图片url']
  for (let i = 1; i <= 15; i++) {
    detailHeaders.push(`问题类型${i}`, `结果值${i}`)
  }
  
  // 创建行数据并计算每行的问题总数
  const detailRowsWithScore = []
  for (let i = 0; i < totalImages.value; i++) {
    const row = ['123456'] // 使用123456代替图片url
    const currentImage = imageIssuesData.value[i] || { issues: [] }
    let issueCount = 0 // 记录这张图片的问题总数
    
    allIssueTypes.forEach((type) => {
      const hasIssue = currentImage.issues.includes(type)
      row.push(type, hasIssue ? '1' : '0')
      if (hasIssue) issueCount++
    })
    
    detailRowsWithScore.push({
      row,
      issueCount
    })
  }

  // 按问题总数倒序排序
  detailRowsWithScore.sort((a, b) => b.issueCount - a.issueCount)

  // 提取排序后的行数据
  const detailRows = detailRowsWithScore.map(item => item.row)

  const detailData = [detailHeaders, ...detailRows]
  const detailSheet = XLSX.utils.aoa_to_sheet(detailData)
  XLSX.utils.book_append_sheet(wb, detailSheet, '图片明细')

  // 导出Excel文件
  XLSX.writeFile(wb, '图片质量诊断结果.xlsx')
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

const placeholderImage = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgZmlsbD0iI2YwZjBmMCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMjAiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIiBmaWxsPSIjNjY2Ij7npLrkvos8L3RleHQ+PC9zdmc+'

const imageIssuesData = ref([
  { 
    id: 1, 
    count: 15, 
    thumbnail: placeholderImage,
    issues: [
      '黑白边',
      '水印图片',
      '拼接图片',
      '重复图片',
      '手机截图',
      '误拍图片',
      '变形图片',
      '卖点贴图片',
      '无包装图片',
      '背标图片',
      '二维码条形码',
      '商品质量异常',
      '角度旋转',
      '过亮或过暗'
    ]
  },
  { 
    id: 2, 
    count: 12, 
    thumbnail: placeholderImage,
    issues: [
      '水印图片',
      '重复图片',
      '手机截图',
      '变形图片',
      '卖点贴图片',
      '无包装图片',
      '背标图片',
      '二维码条形码',
      '商品质量异常',
      '角度旋转',
      '过亮或过暗'
    ]
  },
  { 
    id: 3, 
    count: 10, 
    thumbnail: placeholderImage,
    issues: [
      '拼接图片',
      '水印图片',
      '重复图片',
      '变形图片',
      '卖点贴图片',
      '无包装图片',
      '背标图片',
      '二维码条形码',
      '商品质量异常'
    ]
  },
  { 
    id: 4, 
    count: 8, 
    thumbnail: placeholderImage,
    issues: [
      '手机截图',
      '水印图片',
      '变形图片',
      '卖点贴图片',
      '无包装图片',
      '背标图片',
      '二维码条形码'
    ]
  },
  { 
    id: 5, 
    count: 6, 
    thumbnail: placeholderImage,
    issues: [
      '误拍图片',
      '重复图片',
      '过亮或过暗',
      '角度旋转',
      '变形图片'
    ]
  },
  { 
    id: 6, 
    count: 4, 
    thumbnail: placeholderImage,
    issues: [
      '黑白边',
      '变形图片',
      '卖点贴图片',
      '背标图片'
    ]
  },
  { 
    id: 7, 
    count: 3, 
    thumbnail: placeholderImage,
    issues: [
      '拼接图片',
      '变形图片',
      '误拍图片'
    ]
  },
  { 
    id: 8, 
    count: 2, 
    thumbnail: placeholderImage,
    issues: [
      '手机截图',
      '水印图片'
    ]
  },
  { 
    id: 9, 
    count: 1, 
    thumbnail: placeholderImage,
    issues: [
      '误拍图片'
    ]
  },
  { 
    id: 10, 
    count: 1, 
    thumbnail: placeholderImage,
    issues: [
      '黑白边'
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
          'rgba(255, 228, 181, 0.5)',  // 杏色 - 误拍图片
          'rgba(245, 245, 245, 0.5)',  // 白色 - 白底图片
          'rgba(240, 173, 78, 0.5)',  // 橙色 - 变形图片
          'rgba(147, 112, 219, 0.5)',  // 紫色 - 卖点贴图片
          'rgba(95, 149, 208, 0.5)',  // 蓝色 - 包装图片
          'rgba(255, 99, 132, 0.5)',  // 红色 - 背标图片
          'rgba(255, 159, 64, 0.5)',  // 橙色 - 二维码条形码
          'rgba(75, 192, 192, 0.5)',  // 青色 - 商品质量异常
          'rgba(153, 102, 255, 0.5)',  // 紫色 - 角度旋转
          'rgba(255, 205, 86, 0.5)'  // 黄色 - 光线不足
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
          const type = processedImageTypes.value[index];
          openPreview(type);
        }
      }
    }
  })

  // 添加图片质量问题分布图表
  const issuesCtx = document.getElementById('issuesDistributionChart')
  const chartData = {
    labels: ['图片1', '图片2', '图片3', '图片4', '图片5', '图片6', '图片7', '图片8', '图片9', '图片10'],
    datasets: [{
      label: '低质问题数量',
      data: [14, 11, 9, 7, 5, 4, 3, 2, 1, 1],  // 将第三个数据点从10改为9，将第四个数据点从8改为7，将第五个数据点从6改为5
      backgroundColor: 'rgba(135, 206, 250, 0.6)',
      borderWidth: 0
    }]
  }

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      y: {
        beginAtZero: true,
        max: 15,
        min: 0,
        ticks: {
          stepSize: 3,
          callback: function(value) {
            return value + '个'
          }
        },
        grid: {
          color: 'rgba(0, 0, 0, 0.1)'
        }
      },
      x: {
        grid: {
          display: true,
          color: 'rgba(0, 0, 0, 0.1)'
        }
      }
    },
    plugins: {
      title: {
        display: true,
        text: '图片低质问题数量',
        font: {
          size: 16,
          weight: 'normal'
        }
      },
      legend: {
        display: false
      }
    }
  }

  new Chart(issuesCtx, {
    type: 'bar',
    data: chartData,
    options: {
      ...chartOptions,
      onClick: (event, elements) => {
        if (elements.length > 0) {
          const index = elements[0].index;
          selectedIssueImage.value = imageIssuesData.value[index];
          showIssueDetail.value = true;
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
          <div class="description">本次调用了手持误拍识别、手机截图识别、拼接图检测、白底图识别、变形图识别、黑白边识别、卖点贴识别、重复图识别、包装图检测、背标图检测、二维码/条形码检测、商品质量异常检测、角度旋转检测、光线图识别的服务</div>
          <div class="hint">低质图片类型如下所示：</div>
        </div>
      </div>
      
      <div class="image-types-grid">
        <div 
          v-for="type in sortedImageTypes" 
          :key="type.name" 
          class="image-type-card"
          @click="openPreview(type)"
        >
          <div class="image-type-name">{{ type.name }}</div>
          <div class="image-type-count">{{ type.count }}张 ({{ type.percentage }}%)</div>
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
        <div v-for="service in servicesList" 
             :key="service" 
             :class="['service-tag', { active: selectedServices.includes(service) }]"
             @click="toggleService(service)"
             @mouseover="showServiceDescription = service"
             @mouseleave="showServiceDescription = ''">
          {{ service }}
          <div v-if="showServiceDescription === service" class="description-tooltip">
            {{ getServiceDescription(service) }}
          </div>
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
                <img :src="example.url" :alt="example.url">
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
    <el-dialog
      v-model="showIssueDetail"
      title="图片问题详情"
      width="50%"
      :before-close="handleClose"
      class="issue-detail-dialog">
      <div class="issue-detail-scroll" v-if="selectedIssueImage">
        <div class="issue-detail">
          <div class="image-preview">
            <img :src="selectedIssueImage.thumbnail" alt="问题图片示例">
          </div>
          <div class="issues-list">
            <h3>存在的问题（{{ selectedIssueImage.issues.length }}个）：</h3>
            <ul>
              <li v-for="(issue, index) in selectedIssueImage.issues" :key="index">
                {{ issue }}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<style>
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px;
  font-family: Arial, sans-serif;
  background-color: #f8f9fa;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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

.image-types-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;
  padding: 20px;
  margin: 20px auto;
  max-width: 900px;
}

.image-type-card {
  background: #f7f8fa;
  border-radius: 6px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 0;
  text-align: center;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
}

.image-type-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  background: #ffffff;
}

.image-type-name {
  color: #1D2129;
  font-size: 16px;
  font-weight: 500;
}

.image-type-count {
  color: #86909C;
  font-size: 14px;
}

.service-tags {
  display: grid;
  grid-template-columns: repeat(5, minmax(80px, 1fr));
  gap: 12px;
  margin: 20px 0;
  padding: 0 20px;
}

.service-tag {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 40px;
  padding: 0 8px;
  border-radius: 999px;
  background-color: #F7F8FA;
  color: #4E5969;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  text-align: center;
  width: 100%;
  box-sizing: border-box;
  font-size: 14px;
  font-weight: 400;
}

.service-tag:hover {
  background-color: #F2F3FF;
}

.service-tag.active {
  background-color: #E8F3FF;
  color: #165DFF;
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
  background-color: #e6f7ff;
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

.issue-detail {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.image-preview {
  width: 100%;
  max-width: 400px;
  margin: 0 auto;
}

.image-preview img {
  width: 100%;
  height: auto;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.issues-list {
  width: 100%;
}

.issues-list h3 {
  margin-bottom: 16px;
  color: #333;
}

.issues-list ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 12px;
}

.issues-list li {
  padding: 8px 16px;
  background: #f5f7fa;
  border-radius: 4px;
  color: #606266;
}

.issue-detail-dialog {
  display: flex;
  flex-direction: column;
}

.issue-detail-dialog :deep(.el-dialog__body) {
  padding: 0;
  max-height: 80vh;
}

.issue-detail-scroll {
  max-height: 80vh;
  overflow-y: auto;
  padding: 20px;
}

.issue-detail-scroll::-webkit-scrollbar {
  width: 6px;
}

.issue-detail-scroll::-webkit-scrollbar-track {
  background: #f0f2f5;
  border-radius: 3px;
}

.issue-detail-scroll::-webkit-scrollbar-thumb {
  background: #909399;
  border-radius: 3px;
}

.issue-detail-scroll::-webkit-scrollbar-thumb:hover {
  background: #606266;
}

.issue-detail {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.image-preview {
  width: 100%;
  max-width: 400px;
  margin: 0 auto;
}

.image-preview img {
  width: 100%;
  height: auto;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.issues-list {
  width: 100%;
}

.issues-list h3 {
  margin-bottom: 16px;
  color: #333;
  font-size: 16px;
}

.issues-list ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 12px;
}

.issues-list li {
  padding: 8px 16px;
  background: #f5f7fa;
  border-radius: 4px;
  color: #606266;
  font-size: 14px;
}

.service-tag {
  position: relative;
  display: inline-block;
  padding: 8px 16px;
  margin: 5px;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.service-tag:hover {
  border-color: #165DFF;
  color: #165DFF;
}

.description-tooltip {
  visibility: hidden;
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 14px;
  white-space: nowrap;
  z-index: 1000;
  margin-bottom: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.service-tag:hover .description-tooltip {
  visibility: visible;
}
</style>
