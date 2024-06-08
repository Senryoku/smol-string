<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div class="app">
    <header>
      <h1 style="white-space: nowrap">smol-string</h1>
      <div style="flex-grow: 1"></div>
      <a href="https://github.com/Senryoku/smol-string" target="_blank">
        <img class="icon" src="./assets/img/github-mark-white.svg" alt="GitHub" />
      </a>
      <a href="https://www.npmjs.com/package/smol-string" target="_blank">
        <img class="icon" src="./assets/img/npm-logo-red.svg" alt="npm" />
      </a>
    </header>
    <nav>
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/bench">Benchmarks</RouterLink>
      <div style="flex-grow: 1"></div>
    </nav>
    <div class="content">
      <RouterView />
    </div>
  </div>
</template>

<style scoped>
.app {
  padding-bottom: 5rem;
}

nav {
  display: flex;
  gap: 1em;
  padding: 0.5em 1em;
  background: #000;
}

nav a {
  position: relative;
}

nav a:hover:after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -0.5em;
  height: 1px;
  background: #afd0ee;
}

header {
  display: flex;
  gap: 1em;
  padding: 0.25em 1.5em;
  align-items: center;
}

.content {
  padding: 0 2em;
}

@media (orientation: portrait) {
  .content {
    padding: 0 0.75em;
  }
}

.icon {
  height: 1.5em;
  max-width: 2.5em;
  vertical-align: middle;
}
</style>
