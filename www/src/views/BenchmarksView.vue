<script setup lang="ts">
import { defineAsyncComponent } from 'vue'
const LibBenchmark = defineAsyncComponent(() => import('../components/LibBenchmark.vue'))
</script>

<template>
  <main>
    <h2>Benchmarks</h2>
    <Suspense>
      <LibBenchmark />
      <template #fallback>
        <p>Running benchmarks...</p>
      </template>
    </Suspense>
  </main>
</template>
