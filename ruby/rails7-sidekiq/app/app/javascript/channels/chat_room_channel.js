import consumer from "./consumer"

const url = window.location.href
const path = "chat_rooms/"
const chatRoomId = parseInt(url.substring(url.search(path) + path.length))

if (chatRoomId) {
  consumer.subscriptions.create({ channel: "ChatRoomChannel", chat_room_id: chatRoomId }, {
    connected() {
      console.log(`Subscribed to ${chatRoomId}`)
      // You would do this from the channel itself, but this triggers an action
      // in the Channel so that we can test if instrument the action.
      this.perform("add_connected_message")
    },

    disconnected() {
      console.log(`Disconnected from ${chatRoomId}`)
    },

    received(data) {
      this.appendLine(data)
    },

    appendLine(data) {
      const element = document.querySelector("#chat-room-messages")
      const html = this.createLine(data)
      element.insertAdjacentHTML("beforeend", html)
    },

    createLine(data) {
      return `
        <p>
          <span class="chat-message-date">${data["created_at"]}</span>: <span class="chat-message-body">${data["body"]}</span>
        </p>
      `
    }
  })
}
