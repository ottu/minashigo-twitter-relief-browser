<template>
    <div id="table-component">
        <b-table :data="items" :columns="columns" @click="myEvent" />
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watch, onMounted, PropType } from '@vue/composition-api'
import { Dict, FilterTarget } from './toolbox'

interface TableData {
    columns: Dict[];
    items: RecieveTarget[];
}

interface RecieveTarget {
    id: string,
    level: string,
    name: string
}

export default defineComponent({
    props: {
        recieveStream: {
            type: Boolean,
            default: false
        },
        filters: {
            type: Array as PropType<FilterTarget[]>,
            default: [],
        }
    },
    setup(props) {
        const tableData = reactive<TableData>({
            columns: [
                {
                    field: 'name',
                    label: "名前",                
                },
                {
                    field: 'level',
                    label: "難易度"
                },
                {
                    field: 'id',
                    label: "ID",
                }
            ],
            items: [],
        });

        const myEvent = (e: Object) => {
            console.log(e);
        };

        const filtersUnshift = (r: RecieveTarget) => {
            if (tableData.items.length > 19) {
                tableData.items.length = 19
            }
            tableData.items.unshift(r)
        }

        const filter = (r: RecieveTarget) => {
            console.log("recieved")
            console.log(r)

            if (props.filters.length) {
                props.filters.some((t: FilterTarget) => {
                    console.log(t)
                    if ((t.name == r.name) && (t.level == r.level)) {
                        filtersUnshift(r)
                        return true    
                    }
                })
            } else {
                filtersUnshift(r)
            }
        }

        watch(() => props.recieveStream, 
            (newValue, oldValue) => {
                console.log("watch recieveStream")
                tableData.items = []
            }
        );

        onMounted(()=>{
            console.log("onMounted")
            let ws = new WebSocket('ws://192.168.2.9:8080/ws');
            ws.onopen = (e) => {
                console.log(e)
                ws.send("connected")
            }

            ws.onmessage = (e) => {
                //console.log(e)
                let j: RecieveTarget = JSON.parse(e.data);
                //console.log(j)
                if (props.recieveStream) {
                    filter(j)
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