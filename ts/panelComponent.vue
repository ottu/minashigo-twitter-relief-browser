<template>
    <div id="panel-component">
        <nav class="panel">
            <p class="panel-heading">
                対象マルチ一覧
            </p>
            <div class="panel-block">
                <p class="control has-icons-left">
                    <input class="input" type="text" placeholder="Search">
                    <span class="icon is-left">
                        <b-icon pack="fas" icon="search"></b-icon>
                    </span>
                </p>
            </div>
            <search-target-component
                v-for="target in targets"
                :key="target.id"
                :name="target.name"
                :icon="target.icon"
                :color="target.color">
            </search-target-component>
        </nav>
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, ref } from '@vue/composition-api'
import searchTargetComponent from './searchTargetComponent.vue'


interface Target {
    id: number,
    name: string,
    icon: string,
    color: string,
}

interface PanelData {
    targets: Target[]
}

export default defineComponent({
    components: {
        "search-target-component": searchTargetComponent
    },
    setup() {
        const panelData = reactive<PanelData>({
            "targets": [
            {
                id: 0,
                name: "ラグナロク",
                icon: "fire",
                color: "is-danger"
            },
            {
                id: 1,
                name: "ギガントマキア",
                icon: "water",
                color: "is-info"
            },
            {
                id: 2,
                name: "カタストロフ",
                icon: "wind",
                color: "is-success"
            },
            {
                id: 3,
                name: "ユガ",
                icon: "bolt",
                color: "is-warning"
            },
            {
                id: 4,
                name: "エデン",
                icon: "sun",
                color: ""
            },
            {
                id: 5,
                name: "ミッドウェー",
                icon: "moon",
                color: "is-link"
            }
        ]});

        return {
            ...toRefs(panelData)
        };
    }
})

</script>