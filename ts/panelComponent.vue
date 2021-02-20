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
                :color="target.color"
                :checkboxGroup="target.checkboxGroup"
                :updateHandler="updateHandler">
            </search-target-component>
            <div class="panel-block">
                <div class="columns">
                    <div class="column">
                        <button class="button" @click="resetHandler">Reset</button>
                    </div>
                    <div class="column">
                        <button class="button" @click="execHandler">Start</button>
                    </div>
                </div>
            </div>
        </nav>
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, PropType } from '@vue/composition-api'
import searchTargetComponent from './searchTargetComponent.vue'
import { UpdateHandlerInterface, StartHandlerInterface, FilterTarget, StopHandlerIterface } from './toolbox'

interface TargetSet {
    id: number,
    name: string,
    icon: string,
    color: string,
    checkboxGroup: string[]
}

interface PanelData {
    targets: TargetSet[],
}

export default defineComponent({
    props: {
        startHandler: {
            type: Function as PropType<StartHandlerInterface>,
            required: true
        },
        stopHandler: {
            type: Function as PropType<StopHandlerIterface>,
            required: true
        }
    },
    components: {
        "search-target-component": searchTargetComponent
    },
    setup(props) {
        const panelData = reactive<PanelData>({
            targets: [
                {
                    id: 0,
                    name: "ラグナロク",
                    icon: "fire",
                    color: "is-danger",
                    checkboxGroup: []
                },
                {
                    id: 1,
                    name: "ギガントマキア",
                    icon: "water",
                    color: "is-info",
                    checkboxGroup: []
                },
                {
                    id: 2,
                    name: "カタストロフ",
                    icon: "wind",
                    color: "is-success",
                    checkboxGroup: []
                },
                {
                    id: 3,
                    name: "ユガ",
                    icon: "bolt",
                    color: "is-warning",
                    checkboxGroup: []
                },
                {
                    id: 4,
                    name: "エデン",
                    icon: "sun",
                    color: "is-primary",
                    checkboxGroup: []
                },
                {
                    id: 5,
                    name: "ミッドウェー",
                    icon: "moon",
                    color: "is-dark",
                    checkboxGroup: []
                }
            ],
        });

        const resetHandler = (e: MouseEvent) => {
            console.log("resetHandler")
            panelData.targets.forEach((t: TargetSet)=>{
                t.checkboxGroup = []
            })

            props.stopHandler()
        };

        const execHandler = (e: MouseEvent) => {
            console.log("execHandler")
            let result: FilterTarget[] = []

            panelData.targets.forEach((t: TargetSet) => {

               t.checkboxGroup.forEach((s: string) => {
                   let tmp: FilterTarget = {
                       name: t.name,
                       level: s
                   }
                   result.push(tmp)
               }) 

            })

            props.startHandler(result)
        };

        const updateHandler: UpdateHandlerInterface = (name: string, value: string[]) => {
            console.log("updateHandler")
            panelData.targets.forEach((t: TargetSet)=>{
                if (t.name == name) {
                    console.log(name)
                    console.log(value)
                    t.checkboxGroup = value
                }
            })
        }

        return {
            ...toRefs(panelData),
            resetHandler,
            execHandler,
            updateHandler,
        };
    }
})

</script>