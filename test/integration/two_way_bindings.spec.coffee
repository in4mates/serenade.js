require './../spec_helper'

describe 'Two-way bindings', ->
  beforeEach ->
    @setupDom()

  it 'updates plain model when event triggers', ->
    model = {}
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.querySelector('input')
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(model.name).to.eql("Test")

  it 'updates model when form is submitted if no event name is specified', ->
    model = {}
    @render 'form\n\tinput[type="text" binding=name]\n\t', model, {}
    input = @body.querySelector('input')
    input.value = "Test"
    expect(model.name).to.eql(undefined)
    @fireEvent input.form, "submit"
    expect(model.name).to.eql("Test")

  it 'is triggered before form submits', ->
    model = {}
    stored = null
    @render """
      form[event:submit=store!]
        input[type="text" binding=name]
    """, model, store: -> stored = model.name
    input = @body.querySelector('input')
    input.value = "Test"
    @fireEvent input.form, "submit"
    expect(stored).to.eql("Test")

  it 'updates serenade model when event triggers', ->
    class MyModel extends Serenade.Model
      @property 'name'
    model = new MyModel()
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.querySelector('input')
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(model.name).to.eql("Test")

  it 'sets value of input to models value', ->
    model = {name: "My name"}
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.querySelector('input')
    expect(input.value).to.eql("My name")

  it 'sets value of textarea to models value', ->
    model = {name: "My name"}
    @render 'textarea[binding:keyup=name]', model, {}
    input = @body.querySelector('textarea')
    expect(input.value).to.eql("My name")

  it "sets value of select box to model's value", ->
    model = {name: "My name"}
    @render """
      select[binding:change=name]
        option "Other name"
        option "My name"
    """, model, {}
    input = @body.querySelector('select')
    expect(input.value).to.eql("My name")

  it 'updates the value of input when model changes', ->
    class MyModel extends Serenade.Model
      @property 'name'
    model = new MyModel({name: "My name"})
    @render 'input[type="text" binding:keyup=name]', model, {}
    model.name = "Changed name"
    input = @body.querySelector('input')
    expect(input.value).to.eql("Changed name")

  it 'rejects non-input elements', ->
    expect(=> @render 'div[binding:keyup=name]', {}, {}).to.throw()

  it 'rejects binding to the model itself', ->
    expect(=> @render 'input[binding:keyup=@]', {}, {}).to.throw()

  # Note: jsdom seems to set input.value to "" when we set it to undefined.
  # Actual browsers will set it to "undefined".
  it 'sets value to empty string when model property is undefined', ->
    model = {name: undefined}
    @render 'input[type="text" binding:change=name]', model
    input = @body.querySelector("input")
    expect(input.value).to.eql("")

  it 'sets boolean value for checkboxes', ->
    model = {}
    @render 'input[type="checkbox" binding:change=active]', model, {}
    input = @body.querySelector('input')
    input.checked = true
    @fireEvent input, "change"
    expect(model.active).to.eql(true)

  it 'updates the value of checkbox when model changes', ->
    class MyModel extends Serenade.Model
      @property 'active'
    model = new MyModel({active: false})
    @render 'input[type="checkbox" binding:change=active]', model, {}
    model.active = true
    input = @body.querySelector('input')
    expect(input.checked).to.eql(true)

  it 'sets model value if radio is checked', ->
    model = {}
    @render 'input[type="radio" value="small" binding:change=size]', model, {}
    input = @body.querySelector('input')
    input.checked = true
    @fireEvent input, "change"
    expect(model.size).to.eql("small")

  it 'does not set model value if radio is not checked', ->
    model = {}
    @render 'input[type="radio" value="small" binding:change=size]', model, {}
    input = @body.querySelector('input')
    @fireEvent input, "change"
    expect(model.size).to.eql(undefined)

  it 'checks radio if model value matches its value', ->
    class MyModel extends Serenade.Model
      @property 'size'
    model = new MyModel({size: "small"})
    @render 'input[type="radio" value="large" binding:change=size]', model, {}
    model.size =  "large"
    input = @body.querySelector('input')
    expect(input.checked).to.eql(true)

  it 'unchecks radio if model value does not match its value', ->
    class MyModel extends Serenade.Model
      @property 'size'
    model = new MyModel({size: "small"})
    @render 'input[type="radio" value="large" binding:change=size]', model, {}
    model.size = "medium"
    input = @body.querySelector('input')
    expect(input.checked).to.eql(false)
    
  it 'triggers bound on controller', ->
    model = {}
    input = undefined
    controller = twoWayBound: (element, attributeName, model) ->
      model[attributeName] = "Test"
      input = element
    @render 'input[type="text" binding:keyup=name]', model, controller

    expect(model.name).to.eql("Test")
    expect(input).to.eql(@body.querySelector('input')) 