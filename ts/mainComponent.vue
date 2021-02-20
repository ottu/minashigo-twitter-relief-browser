<template>
    <div id="main-component">
        <b-navbar>
            <template #brand>
                <b-navbar-item>
                    <section class="hero is-link">
                        <div class="hero-body">
                            <p class="title">
                                ミナシゴノシゴト Twitter救援検索
                            </p>
                            <p class="subtitle">
                                サブタイトル
                            </p>
                        </div>
                    </section>
                </b-navbar-item>
            </template>
            <template #start>

            </template>
            <template #end>

            </template>
        </b-navbar>
        <div class="columns">
            <div class="column is-4">
                <panel-component :startHandler="startHandler" :stopHandler="stopHandler"></panel-component>
            </div>
            <div class="column">
                <table-component :filters="mainData.filters" :recieveStream="mainData.recieveStream"></table-component>
            </div>
            <div class="column is-3">
                <etc-component></etc-component>
            </div>


        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive } from '@vue/composition-api'

import PanelComponent from './panelComponent.vue'
import TableComponent from './tableComponent.vue'
import EtcComponent from './etcComponent.vue'

import { FilterTarget, StartHandlerInterface, StopHandlerIterface } from './toolbox'

interface MainData {
    filters: FilterTarget[],
    recieveStream: Boolean
}

export default defineComponent({
    components: {
        'panel-component': PanelComponent,
        'table-component': TableComponent,
        'etc-component': EtcComponent
    },
    setup() {
        let mainData = reactive<MainData>({
            filters: [],
            recieveStream: false
        })

        const stopHandler: StopHandlerIterface = () => {
            console.log("stopHandler")
            mainData.recieveStream = false
        }

        const startHandler: StartHandlerInterface = (args: FilterTarget[]) => {
            console.log("startHandler")
            mainData.filters = args
            mainData.recieveStream = true
        }

        return {
            mainData,
            startHandler,
            stopHandler
        }
    }
})


</script>