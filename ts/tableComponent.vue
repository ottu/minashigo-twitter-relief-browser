<template>
    <div id="table-component">
        <b-table :data="items" :columns="columns" @click="myEvent" />
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watch, onMounted, PropType } from '@vue/composition-api'
import { Dict, FilterTarget } from './toolbox'
import settings from '../config/frontend.json'

interface TableData {
    columns: Dict[];
    items: ReceiveTarget[];
}

interface ReceiveTarget {
    id: string,
    level: string,
    name: string
}

export default defineComponent({
    props: {
        receiveStream: {
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
            let t = e as ReceiveTarget;
            navigator.clipboard.writeText(t.id).then(
                () => {
                    console.log(`Copied ID(${t.id}) to clipboard!`);
                },
                () => {
                    console.log("Unable to write to clipboard...")
                }
            );
        };

        const filtersUnshift = (r: ReceiveTarget) => {
            if (tableData.items.length > 19) {
                tableData.items.length = 19
            }
            tableData.items.unshift(r)
        }

        const filter = (r: ReceiveTarget) => {
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

        watch(() => props.receiveStream, 
            (newValue, oldValue) => {
                console.log("watch receiveStream")
                tableData.items = []
            }
        );

        onMounted(()=>{
            console.log("onMounted")
            let ws = new WebSocket(settings.websocketUrl);
            ws.onopen = (e) => {
                console.log(e)
                ws.send("connected")
            }

            ws.onmessage = (e) => {
                //console.log(e)
                let j: ReceiveTarget = JSON.parse(e.data);
                //console.log(j)
                if (props.receiveStream) {
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