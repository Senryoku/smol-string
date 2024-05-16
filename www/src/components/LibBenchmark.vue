<template>
  <div>
    <BenchmarkResults :results="results" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

import { compress, decompress } from 'smol-string/worker'

// @ts-expect-error
import LZString from '../../lz-string.min.js'

import BenchmarkResults from './BenchmarkResults.vue'

const results = ref({ compressed: {}, decompressed: {}, success: {}, size: {} } as {
  compressed: Record<string, Record<string, number>>
  decompressed: Record<string, Record<string, number>>
  size: Record<string, Record<string, number>>
  success: Record<string, Record<string, boolean>>
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

  if (!results.value['compressed'][file]) {
    results.value['compressed'][file] = {}
    results.value['decompressed'][file] = {}
    results.value['success'][file] = {}
    results.value['size'][file] = {}
  }

  results.value['compressed'][file][method] = compress_time
  results.value['size'][file][method] = 100.0 * (compressed.length / testData.length)
  results.value['decompressed'][file][method] = decompress_time
  results.value['success'][file][method] = testData === decompressed
}

import { json_512kb, json_1mb, rw_medium, rw_large } from '../../../ts-lib/test/common'

onMounted(async () => {
  const usedTests = [
    { name: 'json_512kb', input: JSON.stringify((await json_512kb).default) },
    { name: 'json_1mb', input: JSON.stringify((await json_1mb).default) },
    { name: 'json_4mb', input: JSON.stringify((await rw_medium).default) },
    { name: 'json_8mb', input: JSON.stringify((await rw_large).default) }
  ]

  for (const { name, input } of usedTests) {
    await test('smol-string', name, input, compress, decompress)
    await test('LZString', name, input, LZString.compress, LZString.decompress)
    await test(
      'LZString UTF-16',
      name,
      input,
      LZString.compressToUTF16,
      LZString.decompressFromUTF16
    )
  }
})
</script>

<style scoped></style>
