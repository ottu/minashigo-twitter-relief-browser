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
            <button class="button is-rounded is-fullwidth is-small">EASY</button>
        </div>
        <div class="panel-block">
            <button class="button is-rounded is-fullwidth is-small">NORMAL</button>
        </div>
        <div class="panel-block">
            <button class="button is-rounded is-fullwidth is-small">HARD</button>
        </div>
        <div class="panel-block">
            <button class="button is-rounded is-fullwidth is-small">EXPERT</button>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, PropType } from '@vue/composition-api'

export default defineComponent({
    props: {
        name: {
            type: Object as PropType<string>
        },
        icon: {
            type: Object as PropType<string>
        }
    }
})

</script>