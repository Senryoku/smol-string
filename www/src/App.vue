<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div>
    <header>
      <div class="title">
        <h1 style="white-space: nowrap">smol-string</h1>
        <div style="flex-grow: 1"></div>
        <a href="https://github.com/Senryoku/smol-string" target="_blank">
          <img class="icon" src="./assets/img/github-mark-white.svg" alt="GitHub" />
        </a>
        <a href="https://www.npmjs.com/package/smol-string" target="_blank">
          <img class="icon" src="./assets/img/npm-logo-red.svg" alt="npm" />
        </a>
      </div>
      <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/bench">Benchmarks</RouterLink>
        <RouterLink to="/docs">Documentation</RouterLink>
        <div style="flex-grow: 1"></div>
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

.title {
  display: flex;
  gap: 1em;
  margin: 0.25em 1em;
  align-items: center;
}

.icon {
  height: 1.5em;
  max-width: 2.5em;
  vertical-align: middle;
}
</style>
