import{g as t,o as c,c as r,p,h as i,b as e,i as o}from"./index-hLiLEYad.js";const d={},n=s=>(p("data-v-237e2f41"),s=s(),i(),s),a=n(()=>e("h2",null,"Documentation",-1)),m=n(()=>e("div",null,[e("p",null,[o("More information on the "),e("a",{href:"https://github.com/Senryoku/smol-string"},"GitHub Repository"),o(".")]),e("p",null,[o(" Basic usage: "),e("pre",null,[e("code",null,`import { compress, decompress } from "smol-string";

const input = "Any JS String";

const compressed = compress(input);
const decompressed = decompress(compressed);
`)])]),e("p",null,[o(" Async version: "),e("pre",null,[e("code",null,`import { compress, decompress } from "smol-string/worker";

const compressed = await compress(input);
const decompressed = await decompress(compressed);
`)])])],-1)),l=[a,m];function u(s,_){return c(),r("div",null,l)}const h=t(d,[["render",u],["__scopeId","data-v-237e2f41"]]);export{h as default};
