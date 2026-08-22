import WorkerConstructor from "./worker.ts?worker&inline";

const worker = new WorkerConstructor();

let nextID = 0;
const resolver: Record<number, (str: string) => void> = {};

let markWorkerReady: () => void;
const workerReadyPromise = new Promise<void>((resolve) => {
	markWorkerReady = resolve;
});

worker.onmessage = function (e: { data: { id: number; data: string } }) {
	if (e.data.id == -1 && e.data.data === "worker_ready") {
		markWorkerReady();
		return;
	}

	const id = e.data.id;
	resolver[id](e.data.data);
	delete resolver[id];
};

export async function compress(data: string) {
	await workerReadyPromise;

	const id = nextID++;
	return new Promise<string>((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "compress", id, data });
	});
}

export async function decompress(data: string) {
	await workerReadyPromise;

	const id = nextID++;
	return new Promise<string>((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "decompress", id, data });
	});
}
