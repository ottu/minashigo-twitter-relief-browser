import Vue from 'vue'
import VueCompositionAPI, { createApp } from '@vue/composition-api'

import Buefy from "buefy"
import 'buefy/dist/buefy.css'

import { library } from '@fortawesome/fontawesome-svg-core'
import { fas, faSearch } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
library.add(fas. faSearch)
Vue.component('fa-icon', FontAwesomeIcon)

Vue.use(Buefy, {
    defaultIconPack: 'fas'
})

Vue.use(VueCompositionAPI)

import MainComponent from './mainComponent.vue'

createApp({
    components: {
        'main-component': MainComponent,
    },
})
.mount("#main");