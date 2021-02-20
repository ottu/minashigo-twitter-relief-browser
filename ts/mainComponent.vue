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
                <panel-component></panel-component>
            </div>
            <div class="column">
                <table-component></table-component>
            </div>
            <div class="column is-3">
                <etc-component></etc-component>
            </div>


        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from '@vue/composition-api'

import PanelComponent from './panelComponent.vue'
import TableComponent from './tableComponent.vue'
import EtcComponent from './etcComponent.vue'

export default defineComponent({
    components: {
        'panel-component': PanelComponent,
        'table-component': TableComponent,
        'etc-component': EtcComponent
    }
})


</script>