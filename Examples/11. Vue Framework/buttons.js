
const template = `<div>
<h1>Buttons!!!</h1>

<div class="d-flex flex-wrap ga-3 mb-3">
	<v-btn
		v-for="color in colors"
		@click="ahk.global.WebButtonClickEvent(color)"
		:color="
			lighten > 0 ? color + '-lighten-' + lighten :
			lighten < 0 ? color + '-darken-' + -lighten :
			color
		"
		:size="sizes[size]"
		:rounded="roundings[rounding]"
		:variant="variant"
	>{{ color }}</v-btn>
</div>

<div>Color Adjustment: {{ lighten }}</div>
<v-slider v-model="lighten" show-ticks="always" min="-4" max="5" step="1" tick-size="4"></v-slider>

<div>Size Adjustment: {{ sizes[size] ?? "Default" }}</div>
<v-slider v-model="size" show-ticks="always" min="0" max="4" step="1" tick-size="4"></v-slider>

<div>Rounding: {{ roundings[rounding] ?? "Default" }}</div>
<v-slider v-model="rounding" show-ticks="always" min="0" max="4" step="1" tick-size="4"></v-slider>

<v-select
  label="Variant"
  :items="['elevated', 'flat', 'tonal', 'outlined', 'text', 'plain']"
  v-model="variant"
></v-select>

</div>`

export default {
	data: () => ({
		lighten: 0,
		colors: [
			'red', 'pink', 'purple', 'deep-purple', 'indigo', 'blue',
			'light-blue', 'cyan', 'teal', 'green', 'light-green', 'lime',
			'yellow', 'amber', 'orange', 'deep-orange', 'brown', 'grey',
			'blue-grey', 'black', 'white'
		],
		size: 2,
		sizes: ["x-small", "small", undefined, "large", "x-large"],
		rounding: 2,
		roundings: ["0", "sm", undefined, "lg", "xl"],
		variant: 'elevated',
	}),
	template
}
