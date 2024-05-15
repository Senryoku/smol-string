<template>
  <div>
    <section>
      <h2>What is smol-string?</h2>
      <div>
        <p>
          smol-string is a compression library designed for use with browsers'
          <code>localStorage</code> (and <code>sessionStorage</code>). It serves as a faster
          alternative to
          <a href="https://github.com/pieroxy/lz-string" target="_blank">lz-string</a>.
        </p>
      </div>
    </section>
    <section>
      <h2>Installation</h2>
      <p>
        Install via npm:
        <highlightjs :autodetect="false" language="shell" code="npm install smol-string" />
      </p>
    </section>
    <section>
      <div>
        <h2>Usage</h2>
        <p>
          Basic usage, blocking:
          <highlightjs
            :autodetect="false"
            language="typescript"
            code='import { compress, decompress } from "smol-string";

const input = "Any JS String";

const compressed = compress(input);
const decompressed = decompress(compressed);'
          />
        </p>
        <p>
          Async version, uses a webworker under the hood and returns a promise:
          <highlightjs
            :autodetect="false"
            language="typescript"
            code='import { compress, decompress } from "smol-string/worker";
            
const input = JSON.stringify({ imagine: "this is a large object" });

const compressed = await compress(input);
const decompressed = await decompress(compressed);'
          />
        </p>
      </div>
    </section>

    <section>
      <h2>Benchmarks</h2>
      <p>
        <RouterLink to="/bench"
          >Run the benchmarks comparing smol-string to lz-string directly in your
          browser.</RouterLink
        >
        (Warning: The page might be unresponsive while the benchmarks are running)
      </p>
      <p>Example run in Chrome:</p>
      <img src="../assets/img/bench-compress-min.png" alt="Compression Benchmark Results" />
      <img src="../assets/img/bench-decompress-min.png" alt="Decompression Benchmark Results" />
    </section>
    <section>
      <h2>More Information</h2>
      <p>
        More information on the
        <a href="https://github.com/Senryoku/smol-string">GitHub Repository</a>.
      </p>
    </section>
  </div>
</template>

<style scoped>
p {
  margin-left: 1em;
  margin-bottom: 1em;
}

code {
  font-family: monospace;
}

img {
  display: block;
  margin: auto;
  max-width: 100%;
}
</style>
