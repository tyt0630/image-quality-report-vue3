<script setup>
import { ref, onMounted, computed } from 'vue'
import Chart from 'chart.js/auto'

const totalImages = ref(20)
const showPreview = ref(false)
const selectedType = ref(null)
const selectedServices = ref([])
const showSuccessModal = ref(false)
const showFormModal = ref(false)
const formData = ref({
  qps: '',
  billingAppkey: '',
  onesLink: ''
})

const imageTypes = [
  { 
    name: '黑边图片', 
    count: 5, 
    percentage: 25,
    service: '黑白边识别',
    examples: [
      { url: '/examples/black-border-1.jpg', description: '商品图片四周出现黑边' },
      { url: '/examples/black-border-2.jpg', description: '局部区域出现黑边' }
    ]
  },
  { 
    name: '重复图片', 
    count: 4, 
    percentage: 20,
    service: '重复图识别',
    examples: [
      { url: '/examples/duplicate-1.jpg', description: '同一商品重复上传' },
      { url: '/examples/duplicate-2.jpg', description: '相似角度重复拍摄' }
    ]
  },
  { 
    name: '水印图片', 
    count: 3, 
    percentage: 15,
    service: '水印识别',
    examples: [
      { url: '/examples/watermark-1.jpg', description: '图片包含水印标记' },
      { url: '/examples/watermark-2.jpg', description: '图片包含透明水印' }
    ]
  },
  { 
    name: '拼接图片', 
    count: 3, 
    percentage: 15,
    service: '拼接图检测',
    examples: [
      { url: '/examples/composite-1.jpg', description: '多张图片拼接上传' },
      { url: '/examples/composite-2.jpg', description: '商品细节拼接展示' }
    ]
  },
  { 
    name: '手机截图', 
    count: 3, 
    percentage: 15,
    service: '手机截图识别',
    examples: [
      { url: '/examples/screenshot-1.jpg', description: '手机界面截图上传' },
      { url: '/examples/screenshot-2.jpg', description: '包含状态栏的截图' }
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

// 其他通用服务
const otherServices = [
  '白底图识别',
  '变形图识别',
  '卖点贴识别',
  '主图识别',
  'Logo识别',
  '纯色图识别'
]

// 根据问题类型占比排序服务
const services = [
  ...sortedImageTypes.map(type => type.service),
  ...otherServices
]

// 服务能力描述
const serviceDescriptions = {
  '黑白边识别': '检测给定的商品图像是否存在黑边/白边框',
  '重复图识别': '检测商品图片是否为重复或相似图片',
  '水印识别': '检测商品图片是否包含水印标记',
  '拼接图检测': '识别商品图片是否为多张图片拼接而成',
  '手机截图识别': '检测是否为手机界面的截图',
  '手持误拍识别': '识别商品图片是否存在手持、模糊等问题',
  '白底图识别': '检测商品图片是否为白色背景',
  '变形图识别': '检测商品图片是否存在扭曲变形',
  '卖点贴识别': '识别商品图片是否包含营销标签',
  '主图识别': '判断是否符合主图规范要求',
  'Logo识别': '检测商品图片是否包含品牌标识',
  '纯色图识别': '检测是否为纯色背景图片'
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

onMounted(() => {
  const ctx = document.getElementById('qualityChart')
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: sortedImageTypes.map(type => type.name),
      datasets: [{
        data: sortedImageTypes.map(type => type.count),
        backgroundColor: [
          'rgba(255, 192, 203, 0.5)',  // 粉色 - 黑边图片
          'rgba(144, 238, 144, 0.5)',  // 淡绿色 - 重复图片
          'rgba(135, 206, 235, 0.5)',  // 天蓝色 - 水印图片
          'rgba(221, 160, 221, 0.5)',  // 梅红色 - 拼接图片
          'rgba(255, 218, 185, 0.5)',   // 桃色 - 手机截图
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
    <div class="title-section">
      <h1>图像质量诊断报告</h1>
      <a href="https://km.sankuai.com/collabpage/2693732140" 
         target="_blank" 
         class="help-icon"
         @mouseenter="showHelpTooltip = true"
         @mouseleave="showHelpTooltip = false">
        <span class="icon">!</span>
        <div class="tooltip" v-if="showHelpTooltip">报告解释说明</div>
      </a>
    </div>
    <div class="diagnosis-section">
      <div class="section-header">
        <h2>诊断结果</h2>
        <button class="download-button" @click="downloadResults">
          <span class="download-icon">↓</span>
          下载明细结果
        </button>
      </div>
      <p class="diagnosis-summary">本次共诊断了<span>{{ totalImages }}</span>张图片</p>
      
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
      <p class="description">多选您所需要的服务，一键接入玉树</p>
      <div class="service-tags">
        <div v-for="service in services" 
             :key="service" 
             :class="['service-tag', { active: selectedServices.includes(service) }]"
             @click="toggleService(service)">
          {{ service }}
          <div class="service-tooltip">{{ serviceDescriptions[service] }}</div>
        </div>
      </div>
      <button class="contact-button" @click="handleCreateScene">生成接入场景</button>
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
    <div v-if="showFormModal" class="modal-overlay">
      <div class="form-modal">
        <button class="close-button" @click="showFormModal = false">×</button>
        <h3>创建接入场景</h3>
        <div class="form-content">
          <div class="form-item">
            <label>QPS</label>
            <input type="number" v-model="formData.qps" placeholder="请输入QPS">
          </div>
          
          <div class="form-item">
            <label>授权Appkey</label>
            <input type="text" disabled value="com.sankuai.horus.yushusvc" class="disabled-input">
          </div>
          
          <div class="form-item">
            <label>计费Appkey</label>
            <input type="text" v-model="formData.billingAppkey" placeholder="请输入计费Appkey">
          </div>
          
          <div class="form-item">
            <label>Ones链接</label>
            <input type="text" v-model="formData.onesLink" placeholder="请输入Ones链接">
          </div>
        </div>
        
        <div class="form-actions">
          <button class="submit-button" @click="submitForm">接入</button>
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

.title-section {
  position: relative;
  display: inline-block;
  margin-bottom: 20px;
}

.title-section h1 {
  margin: 0;
}

.help-icon {
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

.help-icon .icon {
  color: #666;
  font-size: 12px;
  font-weight: bold;
  font-style: normal;
}

.help-icon:hover {
  background-color: #dee2e6;
}

.help-icon .tooltip {
  position: absolute;
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

.help-icon .tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border-width: 4px;
  border-style: solid;
  border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
}

.diagnosis-section, .services-section {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 30px;
}

.diagnosis-summary {
  color: #666;
  margin-bottom: 25px;
  font-size: 16px;
}

.diagnosis-summary span {
  color: #007bff;
  font-weight: bold;
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
  background: #28a745;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 16px;
  margin-left: 10px;
}

.contact-button:hover {
  background: #218838;
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
  border-radius: 12px;
  width: 1000px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.close-button {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
  padding: 0 8px;
}

.close-button:hover {
  color: #333;
}

.modal-body {
  padding: 30px;
}

.examples-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.example-item {
  position: relative;
  background: #f8f9fa;
  border-radius: 8px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.example-image {
  width: 100%;
  padding-bottom: 100%;
  position: relative;
  overflow: hidden;
}

.example-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.example-description {
  padding: 12px;
  margin: 0;
  color: #666;
  font-size: 14px;
  text-align: center;
  background: white;
}

.chart-container {
  height: 300px;
  margin: 20px 0;
  padding: 20px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
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

.form-modal {
  background: white;
  border-radius: 8px;
  padding: 24px;
  width: 360px;
  max-width: 90vw;
  position: relative;
}

.form-modal h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  color: #333;
  text-align: center;
}

.form-content {
  margin-bottom: 24px;
}

.form-item {
  margin-bottom: 16px;
}

.form-item label {
  display: block;
  margin-bottom: 8px;
  color: #333;
  font-size: 14px;
}

.form-item input {
  width: calc(100% - 24px);
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}

.form-item input:focus {
  outline: none;
  border-color: #228be6;
}

.disabled-input {
  background-color: #f8f9fa;
  color: #666;
  cursor: not-allowed;
}

.form-actions {
  display: flex;
  justify-content: center;
}

.submit-button {
  padding: 8px 40px;
  border-radius: 20px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
  background-color: #228be6;
  border: 1px solid #228be6;
  color: white;
}

.submit-button:hover {
  background-color: #1c7ed6;
}

.close-button {
  position: absolute;
  right: 16px;
  top: 16px;
  width: 24px;
  height: 24px;
  border-radius: 12px;
  border: none;
  background: none;
  font-size: 20px;
  color: #999;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  transition: all 0.2s;
}

.close-button:hover {
  background-color: #f0f0f0;
  color: #666;
}
</style>
