<template>
  <div>
    <h2>Documentation</h2>
    <div>
      <p>More information on the <a href="https://github.com/Senryoku/smol-string">GitHub Repository</a>.</p>

      <p>
        Basic usage:
        <pre><code>import { compress, decompress } from "smol-string";

const input = "Any JS String";

const compressed = compress(input);
const decompressed = decompress(compressed);
</code></pre>
      </p>
      <p>
        Async version:

        <pre><code>import { compress, decompress } from "smol-string/worker";

const compressed = await compress(input);
const decompressed = await decompress(compressed);
</code></pre>
      </p>
    </div>
  </div>
</template>

<style scoped>
p {
  margin-bottom: 1em;  
}

pre {
  background-color: #15181b;
  padding: 0.5em 1em;
  margin: 0.5em;
  white-space: pre-wrap;
  border-radius: 0.5em;
}
</style>
