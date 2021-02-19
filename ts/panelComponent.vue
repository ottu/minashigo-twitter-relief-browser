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
            <search-target-component v-for="target in targets" :key="target.id" :name="target.name" :icon="target.icon"></search-target-component>
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
}

export default defineComponent({
    components: {
        "search-target-component": searchTargetComponent
    },
    setup() {
        const targets = reactive<Target[]>([
            {
                id: 0,
                name: "ラグナロク",
                icon: "fire"
            },
            {
                id: 1,
                name: "ギガントマキア",
                icon: "water"
            },
            {
                id: 2,
                name: "カタストロフ",
                icon: "wind"
            },
            {
                id: 3,
                name: "ユガ",
                icon: "bolt"
            },
            {
                id: 4,
                name: "エデン",
                icon: "sun"
            },
            {
                id: 5,
                name: "ミッドウェー",
                icon: "moon"
            }
        ]);

        return {
            ...toRefs({targets})
        };
    }
})

</script>