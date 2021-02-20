<template>
    <div :id='"search-target-component-" + icon' :elem="icon">
        <div class="panel-block">
            <span class="icon-text">
                <span class="icon">
                    <b-icon pack="fas" :icon="icon"></b-icon>
                </span>
            </span>
            <span>{{name}}</span>
        </div>
        <section>
            <b-field>
                <b-checkbox-button
                    v-for='level of ["EASY", "NORMAL", "HARD", "EXPERT"]'
                    :key='icon + "-" + level'
                    v-model="injectionMethod"
                    :native-value="level"
                    :type="color"
                    :input="checkboxGroup.includes(level)">
                    {{level}}
                </b-checkbox-button>
            </b-field>
        </section>
        {{checkboxGroup}}
    </div>
</template>

<script lang="ts">
import { defineComponent, reactive, PropType, computed } from '@vue/composition-api'
import { UpdateHandlerInterface } from './toolbox'

export default defineComponent({
    props: {
        name: {
            type: String
        },
        icon: {
            type: String
        },
        color: {
            type: String
        },
        checkboxGroup: {
            type: Array as PropType<string[]>
        },
        updateHandler: {
            type: Function as PropType<UpdateHandlerInterface>,
            required: true
        }
    },
    setup(props) {

        const injectionMethod = computed({
            get: () => props.checkboxGroup,
            set: (v) => props.updateHandler(props.name!, v!)
        })

        const onClick = (e: MouseEvent)=> {
            let target = e.currentTarget as HTMLElement;
            if (target.classList.contains("is-light")) {
                target.classList.remove("is-light")
            } else {
                target.classList.add("is-light")
            }
        };

        return {
            injectionMethod,
            onClick
        }
    }
})

</script>