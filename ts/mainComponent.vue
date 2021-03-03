<template>
    <section>
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
                <div class="column is-narrow">
                    <panel-component :startHandler="startHandler" :stopHandler="stopHandler"></panel-component>
                </div>
                <div class="column">
                    <table-component :filters="filters" :receiveStream="receiveStream"></table-component>
                </div>
                <div class="column is-3">
                    <etc-component></etc-component>
                </div>
            </div>
        </div>
        <b-modal v-model="isInformationModalActive">
            <div class="card">
                <div class="card-content">
                    <div class="content">
                        <h1>使い方</h1>
                        <ul>
                            <li>対象マルチ一覧からフィルタしたい救援を選択する。</li>
                            <li>(選択しない場合は全てが対象になります)</li>
                            <li>Startを押す。</li>
                        </ul>
                        <h3>実装上の仕様</h3>
                        <div>
                            Twitter Streaming APIの仕様上、約2分くらいの間にストリームが1つも流れて来ないと
                            APIへの接続が強制的に閉じられます。
                            その際再接続を試みますが、再接続の試行回数が25回を超えると同一プロセス上からは
                            再接続が出来ないっぽいので、プロセス自体を再起動します。
                            その影響で、それなりの時間が経過したらページリロードを挟んで頂かないと
                            ストリームが全く流れて来ない状況になるかと思います。
                        </div>
                        <div>
                            明確な解決策は、ツイ救援が活発になる事です。
                            実際某お空のツイ救援監視する場合は一晩とか普通に動き続けられるみたいなので…
                        </div>
                        <div>
                            現状、ゲーム内救援だけで十分な感じかと思うのでツイ救援自体がどれだけ利用価値上がるかが
                            勝負所だとは思いますが、そんな感じになってます。
                        </div>
                    </div>
                </div>
            </div>
        </b-modal>
    </section>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs } from '@vue/composition-api'

import PanelComponent from './panelComponent.vue'
import TableComponent from './tableComponent.vue'
import EtcComponent from './etcComponent.vue'

import { FilterTarget, StartHandlerInterface, StopHandlerIterface } from './toolbox'

interface MainData {
    filters: FilterTarget[],
    receiveStream: Boolean,
    isInformationModalActive: Boolean
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
            receiveStream: false,
            isInformationModalActive: true,
        })

        const stopHandler: StopHandlerIterface = () => {
            console.log("stopHandler")
            mainData.receiveStream = false
        }

        const startHandler: StartHandlerInterface = (args: FilterTarget[]) => {
            console.log("startHandler")
            mainData.filters = args
            mainData.receiveStream = false
            mainData.receiveStream = true
        }

        return {
            ...toRefs(mainData),
            startHandler,
            stopHandler
        }
    }
})


</script>