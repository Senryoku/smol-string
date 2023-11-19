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
import { ref, computed } from 'vue'

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

// import { compress, decompress } from 'smol-string'
// import { compressPacked, decompressPacked } from 'smol-string/packed'

import { compress, decompress } from 'smol-string/worker'
import { compressPacked, decompressPacked } from 'smol-string/worker/packed'

// @ts-expect-error
import LZString from '../../lz-string.min.js'

const results = ref({ compressed: {}, decompressed: {}, success: {}, size: {} } as {
  compressed: Record<string, Record<string, number>>
  decompressed: Record<string, Record<string, number>>
  size: Record<string, Record<string, number>>
  success: Record<string, Record<string, boolean>>
})

const chartOptions = {
  responsive: true,
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

const methods = ['smol-string', 'smol-string-packed', 'LZString', 'LZString UTF-16']

const chartDataCompression = computed(() => {
  const datasets = []
  for (const method of methods) {
    datasets.push({
      label: method,
      data: Object.values(results.value['compressed']).map((o) => o[method] ?? 0)
    })
  }

  return {
    labels: Object.keys(results.value['compressed']),
    datasets
  }
})

const chartDataDecompression = computed(() => {
  const datasets = []
  for (const method of methods) {
    datasets.push({
      label: method,
      data: Object.values(results.value['decompressed']).map((o) => o[method] ?? 0)
    })
  }

  return {
    labels: Object.keys(results.value['decompressed']),
    datasets
  }
})

const chartDataSize = computed(() => {
  const datasets = []
  for (const method of methods) {
    datasets.push({
      label: method,
      data: Object.values(results.value['size']).map((o) => o[method] ?? 0)
    })
  }

  return {
    labels: Object.keys(results.value['size']),
    datasets
  }
})

async function test(
  method: string,
  file: string,
  testData: string,
  compress: (str: string) => string | Promise<string>,
  decompress: (str: string) => string | Promise<string>
) {
  const compressed_start = performance.now()
  const compressed = await compress(testData)
  const compress_time = performance.now() - compressed_start

  localStorage.setItem('compressed', compressed)
  const restored_compressed_string = localStorage.getItem('compressed')
  localStorage.removeItem('compressed')

  const decompressed_start = performance.now()
  const decompressed = await decompress(restored_compressed_string!)
  const decompress_time = performance.now() - decompressed_start

  results.value['compressed'][file][method] = compress_time
  results.value['size'][file][method] = 100.0 * (compressed.length / testData.length)
  results.value['decompressed'][file][method] = decompress_time
  results.value['success'][file][method] = testData === decompressed
}

import { json_512kb, json_1mb, rw_medium, rw_large } from '../../../ts-lib/test/common'

const usedTests = [
  { name: 'json_512kb', input: JSON.stringify(await json_512kb) },
  { name: 'json_1mb', input: JSON.stringify(await json_1mb) },
  { name: 'rw_medium', input: JSON.stringify(await rw_medium) },
  { name: 'rw_large', input: JSON.stringify(await rw_large) }
]

for (const { name, input } of usedTests) {
  results.value['compressed'][name] = {}
  results.value['decompressed'][name] = {}
  results.value['success'][name] = {}
  results.value['size'][name] = {}
}

for (const { name, input } of usedTests) {
  await test('smol-string', name, input, compress, decompress)
  await test('smol-string-packed', name, input, compressPacked, decompressPacked)
  await test('LZString', name, input, LZString.compress, LZString.decompress)
  await test('LZString UTF-16', name, input, LZString.compressToUTF16, LZString.decompressFromUTF16)
}
</script>

<style scoped></style>
