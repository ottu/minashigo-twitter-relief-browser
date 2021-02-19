<template>
    <div id="table-component">
        <b-table :data="data" :columns="columns" @click="myEvent" />
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watch, onMounted } from '@vue/composition-api'

interface Dict { [key: string]: string }

interface TableData {
    columns: Dict[];
    data: Dict[];
}

export default defineComponent({
    setup() {
        const tableData = reactive<TableData>({
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

        watch(() => tableData.data, 
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
                tableData.data.unshift(j);
                if (tableData.data.length > 20) {
                    tableData.data.length = 20
                }
            }
        });
        return {
            ...toRefs(tableData),
            myEvent
        }
    }
})

</script>