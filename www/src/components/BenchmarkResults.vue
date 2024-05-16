<template>
  <div>
    <div>
      <h3>Compression Time</h3>
      <div>
        <Bar :options="chartOptions" :data="chartDataCompression!" />
      </div>
    </div>
    <div>
      <h3>Decompression Time</h3>
      <div>
        <Bar :options="chartOptions" :data="chartDataDecompression!" />
      </div>
    </div>
    <div>
      <h3>Compressed Size</h3>
      <div>
        <Bar :options="chartSizeOptions" :data="chartDataSize!" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

import { Bar } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  Colors
} from 'chart.js'

ChartJS.defaults.color = '#ddd'
ChartJS.defaults.borderColor = '#555'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, Colors)

const props = defineProps<{
  results: {
    compressed: Record<string, Record<string, number>>
    decompressed: Record<string, Record<string, number>>
    size: Record<string, Record<string, number>>
    success: Record<string, Record<string, boolean>>
  }
}>()

const chartOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    colors: {
      forceOverride: true
    }
  },
  scales: {
    x: {
      title: {
        display: true,
        text: 'File'
      }
    },
    y: {
      title: {
        display: true,
        text: 'Time (ms)'
      }
    }
  }
}

const chartSizeOptions = structuredClone(chartOptions)
chartSizeOptions.scales.y.title.text = 'Size (%)'

const methods = ['smol-string', 'LZString', 'LZString UTF-16']

const chartDataCompression = computed(() => {
  const datasets = []
  for (const method of methods) {
    datasets.push({
      label: method,
      data: Object.values(props.results.compressed).map((o) => o[method] ?? 0)
    })
  }

  return {
    labels: Object.keys(props.results.compressed),
    datasets
  }
})

const chartDataDecompression = computed(() => {
  const datasets = []
  for (const method of methods) {
    datasets.push({
      label: method,
      data: Object.values(props.results.decompressed).map((o) => o[method] ?? 0)
    })
  }

  return {
    labels: Object.keys(props.results.decompressed),
    datasets
  }
})

const chartDataSize = computed(() => {
  const datasets = []
  for (const method of methods) {
    datasets.push({
      label: method,
      data: Object.values(props.results.size).map((o) => o[method] ?? 0)
    })
  }

  return {
    labels: Object.keys(props.results.size),
    datasets
  }
})
</script>

<style scoped></style>
