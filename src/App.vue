<script setup>
import { ref, onMounted, computed } from 'vue'
import Chart from 'chart.js/auto'
import { ElMessage } from 'element-plus'

const totalImages = ref(20)
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
    count: 5, 
    percentage: 25,
    service: '黑白边识别',
    examples: [
      { url: '/examples/black-border-1.jpg', description: '商品图片四周出现黑边' },
      { url: '/examples/black-border-2.jpg', description: '局部区域出现黑边' },
      { url: '/examples/black-border-3.jpg', description: '图片边缘出现白边' },
      { url: '/examples/black-border-4.jpg', description: '图片周围有明显边框' },
      { url: '/examples/black-border-5.jpg', description: '不规则黑白边' }
    ]
  },
  { 
    name: '重复图片', 
    count: 4, 
    percentage: 20,
    service: '重复图识别',
    examples: [
      { url: '/examples/duplicate-1.jpg', description: '同一商品重复上传' },
      { url: '/examples/duplicate-2.jpg', description: '相似角度重复拍摄' },
      { url: '/examples/duplicate-3.jpg', description: '不同光线重复拍摄' },
      { url: '/examples/duplicate-4.jpg', description: '细节图重复使用' }
    ]
  },
  { 
    name: '水印图片', 
    count: 3, 
    percentage: 15,
    service: '水印识别',
    examples: [
      { url: '/examples/watermark-1.jpg', description: '图片包含水印标记' },
      { url: '/examples/watermark-2.jpg', description: '图片包含透明水印' },
      { url: '/examples/watermark-3.jpg', description: '图片包含品牌水印' }
    ]
  },
  { 
    name: '拼接图片', 
    count: 3, 
    percentage: 15,
    service: '拼接图检测',
    examples: [
      { url: '/examples/composite-1.jpg', description: '多张图片拼接上传' },
      { url: '/examples/composite-2.jpg', description: '商品细节拼接展示' },
      { url: '/examples/composite-3.jpg', description: '不同角度拼接展示' }
    ]
  },
  { 
    name: '手机截图', 
    count: 3, 
    percentage: 15,
    service: '手机截图识别',
    examples: [
      { url: '/examples/screenshot-1.jpg', description: '手机界面截图上传' },
      { url: '/examples/screenshot-2.jpg', description: '包含状态栏的截图' },
      { url: '/examples/screenshot-3.jpg', description: '应用内截图上传' }
    ]
  },
  { 
    name: '误拍图片', 
    count: 2, 
    percentage: 10,
    service: '手持误拍识别',
    examples: [
      { url: '/examples/misshot-1.jpg', description: '图片模糊或失焦' },
      { url: '/examples/misshot-2.jpg', description: '拍摄角度不当' }
    ]
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
    placeholder: '请输入并进行选择'
  },
  {
    label: '业务对接组',
    key: 'businessGroup',
    type: 'select',
    required: true,
    placeholder: '请输入并进行选择'
  },
  {
    label: '关联需求',
    key: 'relatedDemand',
    type: 'select',
    required: false,
    placeholder: '请输入并搜索ones需求'
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
          max: 5,
          ticks: {
            stepSize: 1,
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

      <div class="chart-container" style="width: 80%; height: 300px; margin: 20px auto;">
        <canvas id="qualityChart"></canvas>
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
    <div v-if="showPreview" class="modal-overlay" @click="closePreview">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ selectedType?.name }} - 示例</h3>
          <button class="close-button" @click="closePreview">&times;</button>
        </div>
        <div class="modal-body">
          <div class="examples-grid">
            <div v-for="(example, index) in selectedType?.examples" 
                 :key="index" 
                 class="example-item">
              <div class="example-image">
                <img :src="example.url">
              </div>
              <p class="example-description">{{ example.description }}</p>
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
</style>
