import BenchmarkResults from '@/components/BenchmarkResults.vue';
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
      <div style="margin: 2em">
        <BenchmarkResults :results="ChromeBenchmarkResults" />
      </div>
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

<script setup lang="ts">
import BenchmarkResults from '@/components/BenchmarkResults.vue'

const ChromeBenchmarkResults = {
  compressed: {
    json_512kb: {
      'smol-string': 24.200000000186265,
      LZString: 122.8999999994412,
      'LZString UTF-16': 63.09999999962747
    },
    json_1mb: {
      'smol-string': 35.40000000037253,
      LZString: 120.40000000037253,
      'LZString UTF-16': 126.29999999981374
    },
    json_4mb: {
      'smol-string': 159.69999999925494,
      LZString: 711.5,
      'LZString UTF-16': 600.2999999998137
    },
    json_8mb: {
      'smol-string': 193.09999999962747,
      LZString: 1278.5,
      'LZString UTF-16': 1147.6000000005588
    }
  },
  decompressed: {
    json_512kb: {
      'smol-string': 6.7999999998137355,
      LZString: 16.200000000186265,
      'LZString UTF-16': 16.199999999254942
    },
    json_1mb: {
      'smol-string': 6.099999999627471,
      LZString: 24.40000000037253,
      'LZString UTF-16': 22.5
    },
    json_4mb: {
      'smol-string': 23.100000000558794,
      LZString: 138,
      'LZString UTF-16': 136.19999999925494
    },
    json_8mb: {
      'smol-string': 33.799999999813735,
      LZString: 165.79999999981374,
      'LZString UTF-16': 148.59999999962747
    }
  },
  success: {
    json_512kb: {
      'smol-string': true,
      LZString: true,
      'LZString UTF-16': true
    },
    json_1mb: {
      'smol-string': true,
      LZString: true,
      'LZString UTF-16': true
    },
    json_4mb: {
      'smol-string': true,
      LZString: true,
      'LZString UTF-16': true
    },
    json_8mb: {
      'smol-string': true,
      LZString: true,
      'LZString UTF-16': true
    }
  },
  size: {
    json_512kb: {
      'smol-string': 11.337326050173045,
      LZString: 11.2901420567393,
      'LZString UTF-16': 12.043110807768022
    },
    json_1mb: {
      'smol-string': 9.21076454612789,
      LZString: 9.179052478534002,
      'LZString UTF-16': 9.791018571859656
    },
    json_4mb: {
      'smol-string': 13.949844914424425,
      LZString: 13.807306905265873,
      'LZString UTF-16': 14.727823349027563
    },
    json_8mb: {
      'smol-string': 7.582730870091672,
      LZString: 7.54022476383985,
      'LZString UTF-16': 8.042920284726897
    }
  }
}
</script>

<style scoped>
p {
  margin-left: 1em;
  margin-right: 1em;
  margin-bottom: 1em;
}

@media (orientation: portrait) {
  p {
    margin-left: 0.25em;
    margin-right: 0.25em;
  }
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
