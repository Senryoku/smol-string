<template>
  <div>
    <h2>Home</h2>
    <div>
      <p>
        smol-string is a compression library designed for use with browsers'
        <code>localStorage</code> (and <code>sessionStorage</code>). It serves as a faster
        alternative to <a href="https://github.com/pieroxy/lz-string" target="_blank">lz-string</a>.
      </p>

      <p>Run the <RouterLink to="/bench">Benchmarks</RouterLink> directly in your browser.</p>

      <p>
        More information on the
        <a href="https://github.com/Senryoku/smol-string">GitHub Repository</a>
      </p>
    </div>
  </div>
</template>

<style scoped>
p {
  margin-bottom: 1em;
}

code {
  font-family: monospace;
}
</style>
