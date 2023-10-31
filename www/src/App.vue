<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div>
    <header>
      <h1>smol-string</h1>
      <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/bench">Benchmarks</RouterLink>
        <RouterLink to="/docs">Documentation</RouterLink>
      </nav>
    </header>
    <div>
      <RouterView />
    </div>
  </div>
</template>

<style scoped>
nav {
  display: flex;
  gap: 1em;
  margin: 0.25em 1em;
}
</style>
