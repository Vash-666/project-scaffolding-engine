import { ContactForm } from "./ContactForm"
import { Metadata } from "next"

export const metadata: Metadata = {
  title: "Contact Us",
  description: "Get in touch with us. We'd love to hear from you.",
}

export default function ContactPage() {
  return (
    <div className="container mx-auto px-4 py-12">
      <div className="max-w-2xl mx-auto text-center mb-12">
        <h1 className="text-4xl font-bold tracking-tight mb-4">
          Contact Us
        </h1>
        <p className="text-lg text-muted-foreground">
          Have a question or want to work together? Fill out the form below and we'll get back to you as soon as possible.
        </p>
      </div>

      <ContactForm />

      <div className="max-w-2xl mx-auto mt-16 grid gap-8 md:grid-cols-3 text-center">
        <div>
          <h3 className="font-semibold mb-2">Email</h3>
          <p className="text-sm text-muted-foreground">hello@example.com</p>
        </div>
        <div>
          <h3 className="font-semibold mb-2">Phone</h3>
          <p className="text-sm text-muted-foreground">+1 (555) 123-4567</p>
        </div>
        <div>
          <h3 className="font-semibold mb-2">Location</h3>
          <p className="text-sm text-muted-foreground">San Francisco, CA</p>
        </div>
      </div>
    </div>
  )
}
