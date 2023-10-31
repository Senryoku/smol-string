import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";
import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-packed.js";

describe("compress and decompress via localStorage", async () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = await compress(input);

			localStorage.setItem("compressed", compressed);
			const restored = localStorage.getItem("compressed")!;

			const decompressed = await decompress(restored);

			expect(decompressed).toBe(input);
		});
	}
});

describe("compressPacked and decompressPacked via localStorage", async () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = await compressPacked(input);

			localStorage.setItem("compressed", compressed);
			const restored = localStorage.getItem("compressed")!;

			const decompressed = await decompressPacked(restored);

			expect(decompressed).toBe(input);
		});
	}
});
