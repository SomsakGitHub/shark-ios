import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Binding var player: AVPlayer?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onVideoCaptured = { url in
            videoURL = url
            player = AVPlayer(url: url)
            dismiss()
        }
        vc.onCancel = {
            dismiss()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var onVideoCaptured: ((URL) -> Void)?
    var onCancel: (() -> Void)?

    private var captureSession: AVCaptureSession?
    private var movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var recordingURL: URL?
    private var recordButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }

        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        previewLayer = preview

        captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func setupUI() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)

        let recordBtn = UIButton(type: .custom)
        recordBtn.layer.cornerRadius = 35
        recordBtn.layer.borderWidth = 5
        recordBtn.layer.borderColor = UIColor.red.cgColor
        recordBtn.backgroundColor = .white
        recordBtn.translatesAutoresizingMaskIntoConstraints = false
        recordBtn.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordBtn)
        recordButton = recordBtn

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.widthAnchor.constraint(equalToConstant: 44),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),

            recordBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordBtn.widthAnchor.constraint(equalToConstant: 70),
            recordBtn.heightAnchor.constraint(equalToConstant: 70),
        ])
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func recordTapped() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            recordButton?.backgroundColor = .white
        } else {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            recordingURL = tempURL
            movieOutput.startRecording(to: tempURL, recordingDelegate: self)
            recordButton?.backgroundColor = .red
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            onVideoCaptured?(outputFileURL)
        }
        recordButton?.backgroundColor = .white
    }
}
