<template>
    <div id="table-component">
        <b-table
            :data="items"
            :columns="columns"
            :row-class='(row, index) => row.copied && "is-selected"'
            @click="onRowClick"
            />
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watch, onMounted, PropType } from '@vue/composition-api'
import { SnackbarProgrammatic as Snackbar } from 'buefy'
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
    copied: boolean
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

        const onRowClick = (e: ReceiveTarget) => {
            navigator.clipboard.writeText(e.id).then(
                () => {
                    console.log(`Copied ID(${e.id}) to clipboard!`);
                    e.copied = true
                    Snackbar.open({
                        message: `COPIED ID(${e.id})`,
                        queue: false,
                        duration: 2000,
                    })
                },
                () => {
                    console.log("Unable to write to clipboard...")
                }
            );
        }

        const filtersUnshift = (r: ReceiveTarget) => {
            if (tableData.items.length > 19) {
                tableData.items.length = 19
            }
            tableData.items.unshift(r)
        }

        const filter = (r: ReceiveTarget) => {
            //console.log(r)

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
                let j = JSON.parse(e.data);
                console.log(j);
                if ("keepAlive" in j) {
                    // pass
                } else if ("serverMessage" in j) {
                    Snackbar.open({
                        message: `Streaming API Reconnect.`,
                        queue: false,
                        duration: 2000,
                    })
                } else {
                    let rt: ReceiveTarget = JSON.parse(e.data);
                    rt.copied = false
                    console.log(rt)
                    if (props.receiveStream) {
                        filter(rt);
                    }
                }
            }
        });
        return {
            ...toRefs(tableData),
            onRowClick,
        }
    }
})

</script>