import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/bench',
      name: 'bench',
      component: () => import('../views/BenchmarksView.vue')
    },
    {
      path: '/docs',
      name: 'docs',
      component: () => import('../views/DocumentationView.vue')
    }
  ]
})

export default router
