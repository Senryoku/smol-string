import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

import 'highlight.js/styles/github-dark-dimmed.min.css'
import hljs from 'highlight.js/lib/core'
import typescript from 'highlight.js/lib/languages/typescript'
import shell from 'highlight.js/lib/languages/shell'
import hljsVuePlugin from '@highlightjs/vue-plugin'

const app = createApp(App)

app.use(createPinia())
app.use(router)

hljs.registerLanguage('typescript', typescript)
hljs.registerLanguage('shell', shell)
app.use(hljsVuePlugin)

app.mount('#app')
