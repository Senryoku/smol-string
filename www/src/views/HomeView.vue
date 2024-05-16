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
      'smol-string': 34.900000002235174,
      LZString: 80.19999999925494,
      'LZString UTF-16': 66.90000000223517
    },
    json_1mb: {
      'smol-string': 49.5,
      LZString: 127.5,
      'LZString UTF-16': 118.39999999850988
    },
    json_4mb: {
      'smol-string': 253.19999999925494,
      LZString: 771.8000000007451,
      'LZString UTF-16': 738.8999999985099
    },
    json_8mb: {
      'smol-string': 276.6000000014901,
      LZString: 1458.5,
      'LZString UTF-16': 1440.7999999970198
    }
  },
  decompressed: {
    json_512kb: {
      'smol-string': 5.300000000745058,
      LZString: 15.300000000745058,
      'LZString UTF-16': 15.199999999254942
    },
    json_1mb: {
      'smol-string': 5.899999998509884,
      LZString: 20.399999998509884,
      'LZString UTF-16': 19.600000001490116
    },
    json_4mb: {
      'smol-string': 25.099999997764826,
      LZString: 140.60000000149012,
      'LZString UTF-16': 146.90000000223517
    },
    json_8mb: {
      'smol-string': 28.899999998509884,
      LZString: 154.60000000149012,
      'LZString UTF-16': 168.19999999925494
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
