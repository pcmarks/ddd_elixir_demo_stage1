import {Socket} from "phoenix"

const H_E_COLOR = 52

class HandlingEvent {

  static init() {
    // Create and connect to a web socket monitored by the shipping web server
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()

    // If we are on the page that tracks a cargo's status, set up to
    // join and receive messages for this particular tracking id.
    let trackingInfo = document.getElementById("tracking-info")
    if (trackingInfo) {
      let trackingId = trackingInfo.getAttribute("tracking-id")
      let channel = socket.channel("handling_event:" + trackingId, {})

      channel.join()
        .receive("ok", resp => { console.log("Joined successfully", resp, socket) })
        .receive("error", resp => { console.log("Unable to join", resp) })

      // Listen for new_handling_event messages. The payload contains info about the
      // handling event
      channel.on("new_handling_event", handling_event => {
        let eventContainer = document.getElementById("handling-events")
        let template = document.createElement("tr")

        template.innerHTML = `
          <td>${handling_event.voyage}</td>
          <td>${handling_event.location}</td>
          <td>${handling_event.date}</td>
          <td>${handling_event.time}</td>
          <td>${handling_event.type}</td>
        `
        // Prepend the new handling event to the existing list
        eventContainer.insertBefore(template, eventContainer.firstChild)
        HandlingEvent.highlight_and_fade(template);
      });
      // Listen for a new_cargo_status message. The payload contains the new
      // cargo status as a string.
      channel.on("new_cargo_status", cargo_status => {
        let cargoStatusContainer = document.getElementById("cargo-status")
        cargoStatusContainer.innerHTML = cargo_status.status
        HandlingEvent.highlight_and_fade(cargoStatusContainer);
      })
    }
  }

  static highlight_and_fade(element) {
    // Highlight the new data and then fade away...
    element.style.backgroundColor = 'hsl(' + H_E_COLOR + ', 100%, 70%)';
    var d = 1000;
    for (var i=70; i <= 100; i += 0.1) {
      d += 10;
      (function(ii, dd) {
        setTimeout(function(){
          var next_color = 'hsl(' + H_E_COLOR + ', 100%, ' + ii + '%)';
          element.style.background = next_color
        }, dd);
      })(i, d);
    }
  }
}

document.addEventListener("DOMContentLoaded", () => HandlingEvent.init())

export default HandlingEvent
