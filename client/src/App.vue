<template>
  <div v-if="showLogin" class="login-form container-fluid d-flex flex-column justify-content-center align-items-center">
    <div class="form-group mb-3">
      <input
          type="text"
          class="form-control"
          placeholder="Enter your name"
          required="required"
          v-model="name"
      />
    </div>
    <div>
      <button @click="connectWebSocket" class="btn btn-primary btn-block">Start Chat</button>
    </div>
  </div>
  <div class="chat-area d-flex flex-column justify-content-between" v-else>
    <div class="mt-2">
      <div v-for="message in messageList">
        <div class="card w-100 text-center mb-2" v-if="message.type === 'JOIN'">{{ message.sender }} joined the
          chat.
        </div>
        <div class="card w-100 text-center mb-2" v-else-if="message.type === 'LEAVE'">{{ message.sender }} left the
          chat.
        </div>
        <div class="mb-2 row" v-else>
          <div class="col-1" style="width: 4.3%!important;">
            <img src="/images/user.jpg" alt="User" class="rounded-circle" style="width: 60px; height: 60px;">
          </div>
          <div class="col-3">
            <div>
              {{ message.sender === name ? `You(${name})` : message.sender }}
            </div>
            <div>
              {{ message.content }}
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="d-flex flex-row justify-content-center mb-4">
      <div>
        <input
            style="min-width: 75vw!important;"
            type="text"
            class="form-control"
            placeholder="Enter your message"
            required="required"
            v-model="inputMessage"
        />
      </div>
      <div class="ms-3">
        <button @click="sendMessage" class="btn btn-primary btn-block">Send</button>
      </div>
    </div>
  </div>
</template>
<script setup>
import "bootstrap/dist/css/bootstrap.min.css";
import {ref} from "vue";

let showLogin = ref(true);
let name = ref();
let inputMessage = ref();
let messageList = ref([]);

function sendMessage() {
  if (inputMessage.value && stompClient) {
    let chatMessage = {
      sender: name.value,
      content: inputMessage.value,
      type: 'MESSAGE'
    };
    stompClient.send("/app/chat.send", {}, JSON.stringify(chatMessage));
    inputMessage.value = '';
  }
}

function onMessageReceived(payload) {
  let message = JSON.parse(payload.body);
  messageList.value.push(message);
}

function onConnected() {
  stompClient.subscribe("/topic/public", onMessageReceived);
  stompClient.send("/app/chat.addUser", {}, JSON.stringify({sender: name.value, type: 'JOIN'}));
}

function onError() {
  alert("An error occurred while connecting to the chat server.");
}

function connectWebSocket(event) {
  if (name.value) {
    showLogin.value = false;
    let ws = new SockJS("http://localhost:8080/ws");
    stompClient = Stomp.over(ws);
    stompClient.connect({}, onConnected, onError);
  }
}

let stompClient = null;
</script>
<style scoped>
.login-form {
  height: 100vh;
}

.chat-area {
  height: 100vh;
}

* {
  font-size: large;
  overflow-x: hidden;
}
</style>