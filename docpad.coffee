# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig = {

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# Specify some site properties
		site:
			# The production url of our website
			url: ""

			cid: "YOUR_ACCOUNT_ID"
			collector: "//c.lytics.io" #  "//localhost:8133"  "//c.lytics.io" 

			# The default title of our website
			title: "JSTag Open Source Javascript Event Collection Tag"

			# The website keywords (for SEO) separated by commas
			keywords: """
				event collection, javascript collection, events, analytics, tracking
				"""

			# The website author's name
			author: "Aaron Raddon"

			# The website author's email
			email: "your@email.com"


		# -----------------------------
		# Helper Functions

		# get  url of collector
		getUrl: ->
			ev = @getEnvironments()
			if 'development' in ev
				"//localhost:5353"
			else
				"//c.lytics.io"

		# get  root url path
		getRoot: ->
			ev = @getEnvironments()
			if 'development' in ev
				"/jstag/out"
			else
				"/jstag/out"

		# Get the short name
		getName: ->
			if @document.name 
				@document.title 
			else if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')


	# =================================
	# Collections
	# These are special collections that our website makes available to us

	collections:
		# For instance, this one will fetch in all documents that have pageOrder set within their meta data
		pages: (database) ->
			database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1]).on "add", (model) ->
				model.setMetaDefaults({layout:"default",cmheight:"250px",index_class: "active"})
			

		# This one, will fetch in all documents that have the tag "post" specified in their meta data
		posts: (database) ->
			database.findAllLive({tags: $has: ['post']}, [date:-1])


	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki
	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()
}


# Export our DocPad Configuration
module.exports = docpadConfig