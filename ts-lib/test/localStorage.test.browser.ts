import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";
import { RandomTestData } from "./randomTestData.js";

describe("compress and decompress via localStorage", async () => {
	for (const arr of [TestData, RandomTestData]) {
		for (const { name, input } of arr) {
			test(name, async () => {
				const compressed = compress(input);

				localStorage.setItem("compressed", compressed);
				const restored = localStorage.getItem("compressed")!;

				const decompressed = decompress(restored);

				expect(decompressed).toBe(input);
			});
		}
	}
});
