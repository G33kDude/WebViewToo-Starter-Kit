
const template = `<div>

<h1 class="mb-3">Example Form</h1>

<v-form v-model="valid" @submit.prevent="valid ? ahk.global.FormSubmit($data) : 0">
	<v-row>
		<v-col cols="12" sm="6">
			<v-text-field
				label="Email address"
				placeholder="johndoe@gmail.com"
				type="email"
				v-model="email"
				hide-details="auto"
				:rules="[rules.required]"
			/>
		</v-col>

		<v-col cols="12" sm="6">
			<v-text-field
				v-model="password"
				type="password"
				label="Password"
				hide-details="auto"
				:rules="[rules.required]"
			/>
		</v-col>

		<v-col cols="12" sm="6">
			<v-text-field
				v-model="address"
				label="Address"
				placeholder="1234 Main St"
				hide-details="auto"
			/>
		</v-col>

		<v-col cols="12" sm="6">
			<v-text-field
				v-model="address2"
				label="Address 2"
				placeholder="Apartment, studio, or floor"
				hide-details="auto"
			/>
		</v-col>

		<v-col cols="12" sm="6">
			<v-text-field
				v-model="city"
				label="City"
				hide-details="auto"
			/>
		</v-col>

		<v-col cols="12" sm="4">
			<v-select
				v-model="state"
				label="State"
				:items="['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado']"
			/>
		</v-col>

		<v-col cols="12" sm="2">
			<v-text-field
				v-model="zip"
				label="Zip"
				hide-details="auto"
			/>
		</v-col>
	</v-row>

	<v-checkbox v-model="check" label="Check me out" />
	<v-btn type="submit">Submit</v-btn>
</v-form>

</div>`

export default {
	data: () => ({
		rules: {
			required: value => !!value || 'Field is required',
		},

		email: "",
		password: "",
		address: "",
		address2: "",
		city: "",
		state: "",
		zip: "",
		check: false,
	}),

	template
}
