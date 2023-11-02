// @ts-expect-error
import Worker from "./worker-packed.js?worker&inline";

const worker = new Worker();

let nextID = 0;
const resolver: Record<number, (str: string) => void> = {};

worker.onmessage = function (e: { data: { id: number; data: string } }) {
	const id = e.data.id;
	resolver[id](e.data.data);
	delete resolver[id];
};

export async function compressPacked(data: string) {
	const id = nextID++;
	return new Promise((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "compress", id, data });
	});
}

export async function decompressPacked(data: string) {
	const id = nextID++;
	return new Promise((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "decompress", id, data });
	});
}
