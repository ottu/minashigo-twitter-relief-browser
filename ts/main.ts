import Vue from 'vue'
import VueCompositionAPI, { createApp } from '@vue/composition-api'
import Buefy from "buefy"
import 'buefy/dist/buefy.css'

Vue.use(Buefy)
Vue.use(VueCompositionAPI)

import TableComponent from './tableComponent.vue'

createApp({
    components: {
        'table-component': TableComponent
    },
    
})
.mount("#main");