import { Uint16ArraytoString, copyToWasmBuffer } from "./common.js";
import init from "./module-packed.wasm?init";

type exportsType = {
	allocUint8: (size: number) => number;
	allocUint16: (size: number) => number;
	compressPacked: (ptr: number, length: number) => number;
	decompressPacked: (
		ptr: number,
		length: number,
		tokenCount: number
	) => number;
	free: (ptr: number, length: number) => void;
	memory: any;
};

const instance = await init();
const exports = instance.exports as exportsType;

export function compressPacked(str: string) {
	const { ptr, length } = copyToWasmBuffer(str, exports);

	const ptrToCompressed = exports.compressPacked(ptr, length);

	exports.free(ptr, length);

	const buffer = new Uint16Array(
		exports.memory.buffer.slice(
			ptrToCompressed,
			ptrToCompressed +
				(exports.memory.buffer.byteLength - ptrToCompressed)
		)
	);
	const streamLength = (buffer.at(0)! << 16) + buffer.at(1)!;
	// Includes the tokenCount at the start of the stream (2 * u16).
	const compressedBuffer = buffer.slice(2, streamLength);

	const compressed = Uint16ArraytoString(compressedBuffer);

	exports.free(ptrToCompressed, streamLength);

	return compressed;
}

export function decompressPacked(compressedStr: string) {
	const tokenCount =
		(compressedStr.charCodeAt(0)! << 16) + compressedStr.charCodeAt(1);

	let ptrToCompressed = exports.allocUint16(compressedStr.length - 2);
	let compressed_buffer = new Uint16Array(
		exports.memory.buffer,
		ptrToCompressed,
		compressedStr.length - 2
	);

	for (let i = 2; i < compressedStr.length; i++)
		compressed_buffer[i - 2] = compressedStr.charCodeAt(i);

	const ptrToDecompressedNullTerminated = exports.decompressPacked(
		ptrToCompressed,
		compressedStr.length,
		tokenCount
	);

	exports.free(ptrToCompressed, compressedStr.length);

	const decompressed_buffer = new Uint8Array(
		exports.memory.buffer.slice(
			ptrToDecompressedNullTerminated,
			ptrToDecompressedNullTerminated +
				(exports.memory.buffer.byteLength -
					ptrToDecompressedNullTerminated)
		)
	);
	const decompressed_end = decompressed_buffer.indexOf(0);
	const r = new TextDecoder().decode(
		decompressed_buffer.slice(0, decompressed_end)
	);

	exports.free(ptrToDecompressedNullTerminated, decompressed_end + 1);

	return r;
}
