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
      <img
        src="https://private-user-images.githubusercontent.com/1338143/330982572-20df3f76-959a-428b-8c50-c8f9fbcf1020.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTU4MTQ1OTIsIm5iZiI6MTcxNTgxNDI5MiwicGF0aCI6Ii8xMzM4MTQzLzMzMDk4MjU3Mi0yMGRmM2Y3Ni05NTlhLTQyOGItOGM1MC1jOGY5ZmJjZjEwMjAucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDUxNSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDA1MTVUMjMwNDUyWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9OWYyMjRhYjg4OWYzZTg3ZTQwYjg3YTJkYTQxZjM3MjA5MGVkNTViODE3ZWJlYTVkOGFiZTEzZGVkMzQ1NmZiYyZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.CH_LJrMZJPAgQm9htcK_-2SwY3inhXJDuPrbHydxEVQ"
        alt="Compression Benchmark Results"
      />
      <img
        src="https://private-user-images.githubusercontent.com/1338143/330982603-38d7ca8a-7ef5-4516-b5c1-02db2cdae6b7.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTU4MTQ1OTIsIm5iZiI6MTcxNTgxNDI5MiwicGF0aCI6Ii8xMzM4MTQzLzMzMDk4MjYwMy0zOGQ3Y2E4YS03ZWY1LTQ1MTYtYjVjMS0wMmRiMmNkYWU2YjcucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDUxNSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDA1MTVUMjMwNDUyWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZWIzZmM4YTdhZmZkOWMwOTZhNTc0OTNkYjgzZjJkZjdlMTMwNjczNjI0NjE5NmY3ODY2YWQyNGVmYjdlYjVhNyZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.0l95_2QGK5xgNKaUBR1KK1J7QJrnfNKPbTZbvsR0jBQ"
        alt="Decompression Benchmark Results"
      />
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
