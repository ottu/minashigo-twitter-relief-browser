import Vue from 'vue'
import VueCompositionAPI from '@vue/composition-api'
import Buefy from "buefy"
import 'buefy/dist/buefy.css'

Vue.use(Buefy)
Vue.use(VueCompositionAPI)

import TableComponent from './tableComponent.vue'

new Vue({
    el: "#main",
    components: {
        'table-component': TableComponent
    }
})

let ws = new WebSocket('ws://192.168.2.9:8080/ws');
ws.onopen = (e) => {
    console.log(e)
    ws.send("connected")
}

ws.onmessage = (e) => {
    console.log(e)
}