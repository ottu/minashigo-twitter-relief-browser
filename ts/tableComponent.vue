<template>
    <div>
        {{message}}
        <b-table :data="data" :columns="columns" @click="myEvent" />
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs } from '@vue/composition-api'

interface Dict { [key: string]: string }

interface Data {
    message: string;
    columns: Dict[];
    data: Dict[];
}

export default defineComponent({
    setup() {
        const state = reactive<Data>({
            message: "Hello Minashigo!",
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
            data: [
                { 'name': "ラグナロク", 'level': "HARD", 'id': '0000000000' },
                { 'name': "ラグナロク", 'level': "NORMAL", 'id': '1111111111' },
                { 'name': "ラグナロク", 'level': "EASY", 'id': '2222222222' },
            ],
        });

        const myEvent = (e: Object) => {
            console.log(e);
        }

        return {
            ...toRefs(state),
            myEvent
        }
    }
})


//export default Vue.extend({
//    data() {
//        return {
//            message: "Hello Minashigo!",
//            columns: [
//                {
//                    field: 'name',
//                    label: "名前",                
//                },
//                {
//                    field: 'level',
//                    label: "難易度"
//                },
//                {
//                    field: 'id',
//                    label: "ID",
//                }
//            ],
//            data: [
//                { 'name': "ラグナロク", 'level': "HARD", 'id': '0000000000' },
//                { 'name': "ラグナロク", 'level': "NORMAL", 'id': '1111111111' },
//                { 'name': "ラグナロク", 'level': "EASY", 'id': '2222222222' },
//            ],
//            methods: {
//                myEvent() {
//                    console.log("test2");
//                },
//                myFunc: () => { return "test"; }
//            }
//        }
//    }
//})
//</script>
//