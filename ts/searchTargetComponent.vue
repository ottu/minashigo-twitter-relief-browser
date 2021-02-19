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
        <div class="panel-block">
            <button :class="color" v-on:click="onClick" class="button is-rounded is-fullwidth is-small is-light">EASY</button>
        </div>
        <div class="panel-block">
            <button :class="color" v-on:click="onClick" class="button is-rounded is-fullwidth is-small is-light">NORMAL</button>
        </div>
        <div class="panel-block">
            <button :class="color" v-on:click="onClick" class="button is-rounded is-fullwidth is-small is-light">HARD</button>
        </div>
        <div class="panel-block">
            <button :class="color" v-on:click="onClick" class="button is-rounded is-fullwidth is-small is-light">EXPERT</button>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, PropType } from '@vue/composition-api'

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
        }
    },
    setup() {
        const onClick = (e: MouseEvent)=> {
            let target = e.currentTarget as HTMLElement;
            if (target.classList.contains("is-light")) {
                target.classList.remove("is-light")
            } else {
                target.classList.add("is-light")
            }
        };

        return {
            onClick
        }
    }
})

</script>