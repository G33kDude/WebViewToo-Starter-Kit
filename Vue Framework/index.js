
import page_home from "./home.js"
import page_buttons from "./buttons.js"
import page_form from "./form.js"

const template = `
<v-app :theme="theme">

<v-app-bar border="b" class="ps-4" flat style="-webkit-app-region: drag;" density="compact">

	<v-app-bar-title>WebViewToo</v-app-bar-title>
	<template #append>
		<span style="font-family: Webdings; font-size: 11pt; -webkit-app-region: no-drag;">
			<v-btn variant="text" @click="ahk.Minimize()">0</v-btn>
			<v-btn variant="text" @click="ahk.Maximize()">{{ isMaximized ? 2 : 1 }}</v-btn>
			<v-btn variant="text" style="text-transform: unset" color="red" @click="ahk.Close()">r</v-btn>
		</span>
	</template>
</v-app-bar>

<v-navigation-drawer rail expand-on-hover permanent>
	<v-list density="compact" nav>
		<v-list-item title="Home" prependIcon="mdi-home" @click="page = 'home'" />
		<v-list-item title="Buttons" prependIcon="mdi-view-grid" @click="page = 'buttons'" />
		<v-list-item title="Form" prependIcon="mdi-file-document-outline" @click="page = 'form'" />
	</v-list>

	<template #append>
		<v-list-item
			class="ma-2"
			nav
			prepend-icon="mdi-theme-light-dark"
			title="Theme Switch"
			@click="toggleTheme"
		/>
	</template>
</v-navigation-drawer>

<v-main>
	<v-container class="pa-4" style="max-height: calc(100vh - 48px); overflow-y: auto">
		<page_home v-show="page == 'home'" />
		<page_buttons v-show="page == 'buttons'" />
		<page_form v-show="page == 'form'" />
	</v-container>
</v-main>

</v-app>
`

export default {
	components: { page_home, page_buttons, page_form },

	data: () => ({
		theme: 'dark',
		page: 'home',
		isMaximized: false,
	}),

	mounted() {
		const vm = this

		vm.maximizedObserver = new MutationObserver(() => {
			vm.isMaximized = document.body.classList.contains('ahk-maximized')
		})
		vm.maximizedObserver.observe(document.body, {
			attributes: true,
			attributeFilter: ['class']
		})
	},

	unmounted() {
		vm.maximizedObserver.disconnect()
	},

	methods: {
		toggleTheme() {
			this.theme = this.theme == 'dark' ? 'light' : 'dark'
		},
	},

	template
}
