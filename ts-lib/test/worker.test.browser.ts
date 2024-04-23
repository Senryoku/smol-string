import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string-worker.js";
import { RandomTestData } from "./randomTestData.js";

describe("compress and decompress", () => {
	for (const arr of [TestData, RandomTestData]) {
		for (const { name, input } of arr) {
			test(name, async () => {
				const compressed = await compress(input);
				const decompressed = await decompress(compressed);
				expect(decompressed).toBe(input);
			});
		}
	}
});
