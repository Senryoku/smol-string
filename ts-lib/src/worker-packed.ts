import { compressPacked, decompressPacked } from "./smol-string-packed.js";

export type Message = {
	command: string;
	id: number;
	data: string;
};

self.onmessage = function (e: { data: Message }) {
	const { command, id, data } = e.data;
	switch (command) {
		case "decompress": {
			self.postMessage({ id, data: decompressPacked(data) });
			break;
		}
		case "compress": {
			self.postMessage({ id, data: compressPacked(data) });
			break;
		}
	}
};
