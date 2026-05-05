import { NextRequest, NextResponse } from "next/server"
import * as z from "zod"

// Validation schema matching the client-side form
const contactFormSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Please enter a valid email address"),
  subject: z.string().min(5, "Subject must be at least 5 characters"),
  message: z.string().min(10, "Message must be at least 10 characters"),
})

export async function POST(request: NextRequest) {
  try {
    // Parse request body
    const body = await request.json()
    
    // Validate input
    const result = contactFormSchema.safeParse(body)
    
    if (!result.success) {
      return NextResponse.json(
        {
          error: "Validation failed",
          details: result.error.errors,
        },
        { status: 400 }
      )
    }
    
    const { name, email, subject, message } = result.data
    
    // TODO: Implement actual email sending
    // For now, we just log and return success
    // In production, you would:
    // 1. Send email using Resend, SendGrid, AWS SES, etc.
    // 2. Store in database if needed
    // 3. Add rate limiting to prevent spam
    
    console.log("Contact form submission:", {
      name,
      email,
      subject,
      message,
      timestamp: new Date().toISOString(),
    })
    
    // Simulate processing delay (remove in production)
    await new Promise((resolve) => setTimeout(resolve, 500))
    
    return NextResponse.json(
      {
        success: true,
        message: "Thank you for your message! We'll get back to you soon.",
      },
      { status: 200 }
    )
  } catch (error) {
    console.error("Contact form error:", error)
    
    return NextResponse.json(
      {
        error: "Failed to process your message. Please try again later.",
      },
      { status: 500 }
    )
  }
}

// Optional: Add GET method for health check
export async function GET() {
  return NextResponse.json(
    {
      status: "Contact API is running",
    },
    { status: 200 }
  )
}
