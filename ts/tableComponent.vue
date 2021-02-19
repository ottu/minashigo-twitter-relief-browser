<template>
    <div id="table-component">
        {{message}}
        <b-table :data="data" :columns="columns" @click="myEvent" />
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watch, onMounted } from '@vue/composition-api'

interface Dict { [key: string]: string }

interface State {
    message: string;
    columns: Dict[];
    data: Dict[];
}

export default defineComponent({
    setup() {
        const state = reactive<State>({
            message: "Hello Minashigo!",
            columns: [
                {
                    field: 'Name',
                    label: "名前",                
                },
                {
                    field: 'Lv',
                    label: "難易度"
                },
                {
                    field: 'ID',
                    label: "ID",
                }
            ],
            data: [],
        });

        const myEvent = (e: Object) => {
            console.log(e);
        };

        watch(() => state.data, 
            (newValue, oldValue) => {
                //console.log(`${oldValue} -> ${newValue}`);
            }
        );

        onMounted(()=>{
            let ws = new WebSocket('ws://192.168.2.9:8080/ws');
            ws.onopen = (e) => {
                console.log(e)
                ws.send("connected")
            }

            ws.onmessage = (e) => {
                //console.log(e)
                let j = JSON.parse(e.data);
                //console.log(j)
                state.data.unshift(j);
                if (state.data.length > 20) {
                    state.data.length = 20
                }
            }
        });
        return {
            ...toRefs(state),
            myEvent
        }
    }
})

</script>